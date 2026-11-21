#!/usr/bin/env bash
set -Eeuo pipefail

# bashbrew arch to docker-release-arch
declare -A dockerArches=(
	['amd64']='x86_64'
	['arm32v6']='armel'
	['arm32v7']='armhf'
	['arm64v8']='aarch64'
	['ppc64le']='ppc64le'
	['riscv64']='riscv64'
	['s390x']='s390x'
	['windows-amd64']='x86_64'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
	json='{}'
else
	json="$(< versions.json)"
fi
versions=( "${versions[@]%/}" )

scriptPid="$$" # so we can kill the script even from a subshell
fatal() {
	echo >&2 "error: $*"
	kill "$scriptPid"
	exit 1
}
_curl() {
	exec 42>&1
	local code
	code="$(curl --silent --location -o /dev/fd/42 --write-out '%{http_code}' "$@")"
	case "$code" in
		200) return 0 ;;
		404) return 1 ;;
	esac
	fatal "unexpected status code $code while fetching: $*"
}

# prints the (numeric) release tags of a GitHub repository, newest first -- optionally limited to a "series" ("2.4" matches "2.4.0", "2.4.1", etc)
githubTags() {
	local repo="$1"; shift
	local series="${1:-}"
	git ls-remote --tags "https://github.com/$repo.git" \
		| jq --raw-input --null-input --raw-output --arg series "$series" '
			[
				inputs
				| capture("refs/tags/v(?<version>[0-9.]+)($|\\^)").version
				| select($series == "" or startswith($series + "."))
			]
			| unique_by(split(".") | map(tonumber? // .))
			| reverse[]
		'
}

# prints the contents of the given checksum files (assets) of a GitHub release, or returns non-zero if the release is missing any of them
# (assets are named with "%VERSION%" standing in for the release version, and a leading "?" makes an asset optional)
githubReleaseChecksums() {
	local repo="$1"; shift
	local version="$1"; shift
	local asset optional piece checksums=
	for asset; do
		optional=
		case "$asset" in
			'?'*) optional=1; asset="${asset#'?'}" ;;
		esac
		asset="${asset//%VERSION%/$version}"
		if piece="$(_curl "https://github.com/$repo/releases/download/v$version/$asset")"; then
			checksums+="$piece"$'\n'
		elif [ -z "$optional" ]; then
			return 1
		fi
	done
	printf '%s' "$checksums"
}

# turns the contents of "sha256sum" files into { version, arches: { bashbrewArch: { sha256, file, url } } } (and insists on both "amd64" and "arm64v8")
# - $repo and $version are the release in question
# - $config.file is a regular expression with an "arch" group (and optionally an "os" group, which defaults to "linux" and prefixes everything else, as in "windows-amd64") matching filenames
# - $config.arches maps the "arch" group to bashbrew architectures
# - $config.skip is a regular expression of files to ignore (which defaults to the "*.json" attestations)
checksumsToArches='
	split("\n")
	| map(
		# skips blank lines (and PGP armor, for files like runc.sha256sum)
		capture("^(?<sha256>[0-9a-f]{64}) [ *]?(?<file>.+)$")
		| select(.file | test($config.skip // "[.]json$") | not)
		| .url = "https://github.com/\($repo)/releases/download/v\($version)/\(.file)"
		| .file as $file
		| { (
			$file
			| capture($config.file)
			// error("failed to parse os-arch from filename: \($file)")
			| if .os == null or .os == "linux" then "" else .os + "-" end
			+ ($config.arches[.arch] // error("unknown architecture in filename: \($file)"))
		): . }
	)
	| add
	| if has("amd64") and has("arm64v8") then
		.
	else
		error("missing \(if has("amd64") then "arm64v8" else "amd64" end) in release \($version) of \($repo)")
	end
	| { version: $version, arches: . }
'

# usage: githubRelease REPO SERIES CONFIG ASSET [ASSET ...]
# prints the newest release of REPO (in SERIES, if not empty) that has all the checksum ASSET files, as per "checksumsToArches" (see "githubReleaseChecksums" for ASSET and "checksumsToArches" for CONFIG, which is a jq object literal)
githubRelease() {
	local repo="$1"; shift
	local series="$1"; shift
	local config="$1"; shift

	local configJson
	configJson="$(jq --null-input --compact-output "$config")" || return "$?"

	local versions
	versions="$(githubTags "$repo" "$series")" || return "$?"

	local version checksums
	for version in $versions; do
		if checksums="$(githubReleaseChecksums "$repo" "$version" "$@")"; then
			jq <<<"$checksums" --raw-input --slurp --compact-output --arg repo "$repo" --arg version "$version" --argjson config "$configJson" "$checksumsToArches"
			return "$?"
		fi
	done
	fatal "failed to determine $repo${series:+ $series} version!"
}

# prints { KEYUrl, KEYSha256 } for the given download.docker.com URL, or returns non-zero if it doesn't exist (but a missing or malformed checksum is fatal)
dockerArtifact() {
	local key="$1"; shift
	local url="$1"; shift
	_curl --head "$url" > /dev/null || return 1
	local sha256
	sha256="$(_curl "$url.sha256")" || fatal "missing checksum for $url"
	sha256="${sha256%% *}"
	if [[ ! "$sha256" =~ ^[[:xdigit:]]{64}$ ]]; then
		fatal "invalid checksum for $url: '$sha256'"
	fi
	# (our caller treats a non-zero exit as "does not exist", so anything else going wrong here has to be fatal instead)
	jq --null-input --compact-output --arg key "$key" --arg url "$url" --arg sha256 "$sha256" '
		{
			($key + "Url"): $url,
			($key + "Sha256"): $sha256,
		}
	' || fatal "failed to generate JSON for $url"
}

# prints the "X.Y" series of the given "ARG NAME_VERSION=vX.Y.Z" (from moby's Dockerfile)
mobySeries() {
	local dockerfile="$1"; shift
	local name="$1"; shift
	jq <<<"$dockerfile" --raw-input --null-input --raw-output --arg name "$name" '
		[
			inputs
			| capture("^ARG \($name)_VERSION=v(?<major>[0-9]+)[.](?<minor>[0-9]+)[.]")
			| "\(.major).\(.minor)"
		]
		| if length == 1 then
			.[0]
		else
			error("expected exactly one \($name)_VERSION, not \(length)")
		end
	'
}

dindLatest="$(
	_curl -H 'Accept: application/json' 'https://github.com/moby/moby/commits/master/hack/dind.atom' \
		| jq -r '.payload | first(.. | .commits?[]?.oid)'
)"

dockerVersions="$(
	git ls-remote --tags https://github.com/moby/moby.git \
		| jq --raw-input --null-input --raw-output '
			[ inputs | capture("refs/tags/(docker-)?v(?<version>[0-9.a-z-]+)($|\\^)") | .version ]
			| unique_by( split(".") | map(tonumber? // .) )
			| reverse[]
		'
)"

# checksums.txt -> linux + *bsd checksums
# checksums-signed.txt -> windows + darwin checksums (see also https://github.com/docker/buildx/pull/3978)
buildx="$(
	githubRelease docker/buildx '' '{
		file: "[.](?<os>linux|windows|darwin|[a-z0-9]*bsd)-(?<arch>[^.]+)(?<ext>[.]exe)?$",
		arches: {
			"amd64": "amd64",
			"arm-v6": "arm32v6",
			"arm-v7": "arm32v7",
			"arm64": "arm64v8",
			"ppc64le": "ppc64le",
			"riscv64": "riscv64",
			"s390x": "s390x",
		},
	}' checksums.txt checksums-signed.txt
)"
buildxVersion="$(jq <<<"$buildx" --raw-output '.version')"

compose="$(
	githubRelease docker/compose '' '{
		file: "-(?<os>linux|windows|darwin|freebsd|openbsd)-(?<arch>[^.]+)(?<ext>[.]exe)?$",
		arches: {
			aarch64: "arm64v8",
			armv6: "arm32v6",
			armv7: "arm32v7",
			ppc64le: "ppc64le",
			riscv64: "riscv64",
			s390x: "s390x",
			x86_64: "amd64",
		},
	}' checksums.txt
)"
composeVersion="$(jq <<<"$compose" --raw-output '.version')"

for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"
	export version rcVersion
	channel='stable'

	versionOptions="$(grep "^$rcVersion[.]" <<<"$dockerVersions")"

	rcGrepV='-v'
	if [ "$rcVersion" != "$version" ]; then
		rcGrepV=
		channel='test'
	fi

	if ! fullVersion="$(grep $rcGrepV -E -- '-(rc|tp|beta)' <<<"$versionOptions" | head -1)" || [ -z "$fullVersion" ]; then
		if currentNull="$(jq -r '.[env.version] == null' versions.json)" && [ "$currentNull" = 'true' ]; then
			echo >&2 "warning: skipping '$version' (does not appear to be released yet)"
			json="$(jq <<<"$json" -c '.[env.version] = null')"
			continue
		fi
		echo >&2 "error: cannot find full version for $version"
		exit 1
	fi

	# if this is a "-rc" release, let's make sure the release it contains isn't already GA (and thus something we should not publish anymore)
	if [ "$rcVersion" != "$version" ] && rcFullVersion="$(jq <<<"$json" -r '.[env.rcVersion].version // ""')" && [ -n "$rcFullVersion" ]; then
		latestVersion="$({ echo "$fullVersion"; echo "$rcFullVersion"; } | sort -V | tail -1)"
		if [[ "$fullVersion" == "$rcFullVersion"* ]] || [ "$latestVersion" = "$rcFullVersion" ]; then
			# "x.y.z-rc1" == x.y.z*
			echo >&2 "warning: skipping/removing '$version' ('$rcVersion' is at '$rcFullVersion' which is newer than '$fullVersion')"
			json="$(jq <<<"$json" -c '.[env.version] = null')"
			continue
		fi
	fi

	# the download.docker.com archives no longer include containerd or runc, so we use the "X.Y" series moby pins and go find the latest patch release of each
	mobyDockerfile="$(_curl "https://github.com/moby/moby/raw/docker-v$fullVersion/Dockerfile")" || fatal "failed to fetch moby's Dockerfile for $fullVersion"
	# (these have to be separate assignments, not "$(...)" arguments to "githubRelease" below, so that a failure here aborts instead of silently becoming an empty series, which would mean "any release")
	containerdSeries="$(mobySeries "$mobyDockerfile" 'CONTAINERD')"
	runcSeries="$(mobySeries "$mobyDockerfile" 'RUNC')"

	# the (static) containerd tarballs have a "bin/" directory with "containerd", "ctr", the shim, etc in them
	containerd="$(
		githubRelease containerd/containerd "$containerdSeries" '{
			file: "-(?<os>linux)-(?<arch>[^.]+)[.]tar[.]gz$",
			arches: {
				"amd64": "amd64",
				"arm64": "arm64v8",
				"ppc64le": "ppc64le",
				"riscv64": "riscv64",
				"s390x": "s390x",
			},
		}' \
			containerd-static-%VERSION%-linux-amd64.tar.gz.sha256sum \
			containerd-static-%VERSION%-linux-arm64.tar.gz.sha256sum \
			?containerd-static-%VERSION%-linux-ppc64le.tar.gz.sha256sum \
			?containerd-static-%VERSION%-linux-riscv64.tar.gz.sha256sum \
			?containerd-static-%VERSION%-linux-s390x.tar.gz.sha256sum
	)"
	containerdVersion="$(jq <<<"$containerd" --raw-output '.version')"

	# "runc.sha256sum" is PGP-signed
	# https://github.com/opencontainers/runc/blob/v1.5.3/script/lib.sh ("armel" is GOARM=5, which runs on our "arm32v6", and "armhf" is GOARM=7, which only runs on "arm32v7")
	runc="$(
		githubRelease opencontainers/runc "$runcSeries" '{
			file: "^runc[.](?<arch>.+)$",
			skip: "[.]386$|[.]tar[.]xz$",
			arches: {
				"amd64": "amd64",
				"arm64": "arm64v8",
				"armel": "arm32v6",
				"armhf": "arm32v7",
				"ppc64le": "ppc64le",
				"riscv64": "riscv64",
				"s390x": "s390x",
			},
		}' runc.sha256sum
	)"
	runcVersion="$(jq <<<"$runc" --raw-output '.version')"

	echo "$version: $fullVersion (containerd $containerdVersion, runc $runcVersion, buildx $buildxVersion, compose $composeVersion)"

	export fullVersion dindLatest
	doc="$(
		jq --null-input --compact-output --argjson containerd "$containerd" --argjson runc "$runc" --argjson buildx "$buildx" --argjson compose "$compose" '{
			version: env.fullVersion,
			arches: {},
			dindCommit: env.dindLatest,
			containerd: $containerd,
			runc: $runc,
			buildx: $buildx,
			compose: $compose,
		}'
	)"

	for bashbrewArch in "${!dockerArches[@]}"; do
		arch="${dockerArches[$bashbrewArch]}"

		# every architecture has "cli", and that is what decides whether we support it (everything else is optional per-architecture, and just narrows down what we can build for it)
		artifacts=( cli )
		case "$bashbrewArch" in
			windows-*)
				urlBase="https://download.docker.com/win/static/$channel/$arch"
				ext='zip'
				# no dind for Windows, so no need for the engine either
				;;

			*)
				urlBase="https://download.docker.com/linux/static/$channel/$arch"
				ext='tgz'
				# (not every architecture has these -- riscv64 does not have either of the latter two, for example)
				artifacts+=( engine rootlessExtras )
				;;
		esac

		for artifact in "${artifacts[@]}"; do
			case "$artifact" in
				cli) file="docker-cli_$fullVersion.$ext" ;;
				engine) file="docker-engine_$fullVersion.$ext" ;;
				rootlessExtras) file="docker-rootless-extras-$fullVersion.$ext" ;;
			esac
			if artifactJson="$(dockerArtifact "$artifact" "$urlBase/$file")"; then
				doc="$(jq <<<"$doc" --compact-output --arg arch "$bashbrewArch" --argjson artifact "$artifactJson" '.arches[$arch] += $artifact')"
			elif [ "$artifact" = 'cli' ]; then
				continue 2
			fi
		done
	done

	# amd64 and arm64v8 are always expected to have every single artifact
	missing="$(
		jq <<<"$doc" --raw-output '
			. as $doc
			| [
				(
					"amd64",
					"arm64v8",
					empty
				) as $arch
				| (
					[ "arches", $arch, "cliUrl" ],
					[ "arches", $arch, "engineUrl" ],
					[ "arches", $arch, "rootlessExtrasUrl" ],
					[ "containerd", "arches", $arch ],
					[ "runc", "arches", $arch ],
					empty
				) as $path
				| select($doc | getpath($path) | not)
				| $path
				| join(".")
			]
			| join(", ")
		'
	)"
	if [ -n "$missing" ]; then
		fatal "missing '$missing' for '$version'; cowardly refusing to continue! (because this is almost always a scraping flake or similar bug)"
	fi

	hasWindows="$(jq <<<"$doc" --raw-output '.arches | has("windows-amd64")')"

	# order here controls the order of the library/ file
	for variant in \
		cli \
		dind \
		dind-rootless \
		windows/windowsservercore-ltsc2025 \
		windows/windowsservercore-ltsc2022 \
	; do
		base="${variant%%/*}" # "buster", "windows", etc.
		if [ "$base" = 'windows' ] && [ "$hasWindows" != 'true' ]; then
			continue
		fi
		export variant
		doc="$(jq <<<"$doc" -c '.variants += [ env.variant ]')"
	done

	json="$(jq <<<"$json" -c --argjson doc "$doc" '
		.[env.version] = $doc
		# make sure both "XX.YY" and "XX.YY-rc" always exist
		| .[env.rcVersion] //= null
		| .[env.rcVersion + "-rc"] //= null
	')"
done

jq <<<"$json" -S . > versions.json
