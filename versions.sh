#!/usr/bin/env bash
set -Eeuo pipefail

# bashbrew arch to docker-release-arch
declare -A dockerArches=(
	['amd64']='x86_64'
	['arm32v6']='armel'
	['arm32v7']='armhf'
	['arm64v8']='aarch64'
	['ppc64le']='ppc64le'
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

# "tac|tac" for http://stackoverflow.com/a/28879552/433558
dindLatest="$(curl -fsSL 'https://github.com/docker/docker/commits/master/hack/dind.atom' | tac|tac | awk -F '[[:space:]]*[<>/]+' '$2 == "id" && $3 ~ /Commit/ { print $4; exit }')"

dockerVersions="$(
	git ls-remote --tags https://github.com/docker/docker.git \
		| cut -d$'\t' -f2 \
		| grep '^refs/tags/v[0-9].*$' \
		| sed 's!^refs/tags/v!!; s!\^{}$!!' \
		| sort -u \
		| gawk '
			{ data[lines++] = $0 }

			# "beta" sorts lower than "tp" even though "beta" is a more preferred release, so we need to explicitly adjust the sorting order for RCs
			# also, "18.09.0-ce-beta1" vs "18.09.0-beta3"
			function docker_version_compare(i1, v1, i2, v2, l, r) {
				l = v1; gsub(/-ce/, "", l); gsub(/-tp/, "-alpha", l)
				r = v2; gsub(/-ce/, "", r); gsub(/-tp/, "-alpha", r)
				patsplit(l, ltemp, /[^.-]+/)
				patsplit(r, rtemp, /[^.-]+/)
				for (i = 0; i < length(ltemp) && i < length(rtemp); ++i) {
					if (ltemp[i] < rtemp[i]) {
						return -1
					}
					if (ltemp[i] > rtemp[i]) {
						return 1
					}
				}
				return 0
			}

			END {
				asort(data, result, "docker_version_compare")
				for (i in result) {
					print result[i]
				}
			}
		'
)"

buildxVersions="$(
	git ls-remote --tags https://github.com/docker/buildx.git \
		| cut -d$'\t' -f2 \
		| grep '^refs/tags/v[0-9].*$' \
		| sed 's!^refs/tags/v!!; s!\^{}$!!' \
		| grep -vE -- '-rc' \
		| sort -ruV
)"
buildx=
buildxVersion=
for buildxVersion in $buildxVersions; do
	if checksums="$(curl -fsSL "https://github.com/docker/buildx/releases/download/v${buildxVersion}/checksums.txt")"; then
		buildx="$(jq <<<"$checksums" -csR --arg version "$buildxVersion" '
			rtrimstr("\n") | split("\n")
			| map(
				split(" [ *]?"; "")
				| {
					sha256: .[0],
					file: .[1],
					url: ("https://github.com/docker/buildx/releases/download/v" + $version + "/" + .[1]),
				}
				| { (
					.file
					| capture("[.](?<os>linux|windows|darwin)-(?<arch>[^.]+)([.]|$)")
					// error("failed to parse os-arch from filename: " + .[1])
					| if .os == "linux" then "" else .os + "-" end
					+ ({
						"amd64": "amd64",
						"arm-v6": "arm32v6",
						"arm-v7": "arm32v7",
						"arm64": "arm64v8",
						"ppc64le": "ppc64le",
						"riscv64": "riscv64",
						"s390x": "s390x",
					}[.arch] // error("unknown buildx architecture: " + .arch))
				): . }
			)
			| add
			| {
				version: $version,
				arches: .,
			}
		')"
		break
	fi
done
if [ -z "$buildx" ]; then
	echo >&2 'error: failed to determine buildx version!'
	exit 1
fi

composeVersions="$(
	git ls-remote --tags https://github.com/docker/compose.git \
		| cut -d$'\t' -f2 \
		| grep '^refs/tags/v[0-9].*$' \
		| sed 's!^refs/tags/v!!; s!\^{}$!!' \
		| sort -ruV
)"
compose=
composeVersion=
for composeVersion in $composeVersions; do
	if checksums="$(curl -fsSL "https://github.com/docker/compose/releases/download/v${composeVersion}/checksums.txt")"; then
		compose="$(jq <<<"$checksums" -csR --arg version "$composeVersion" '
			rtrimstr("\n") | split("\n")
			| map(
				split(" *")
				| {
					sha256: .[0],
					file: .[1],
					url: ("https://github.com/docker/compose/releases/download/v" + $version + "/" + .[1]),
				}
				| { (
					.file
					| ltrimstr("docker-compose-")
					| rtrimstr(".exe")
					| split("-")
					| if .[0] == "linux" then "" else .[0] + "-" end
					+ ({
						aarch64: "arm64v8",
						armv6: "arm32v6",
						armv7: "arm32v7",
						ppc64le: "ppc64le",
						riscv64: "riscv64",
						s390x: "s390x",
						x86_64: "amd64",
					}[.[1]] // error("unknown compose architecture: " + .[1]))
				): . }
			)
			| add
			| {
				version: $version,
				arches: .,
			}
		')"
		break
	fi
done
if [ -z "$compose" ]; then
	echo >&2 'error: failed to determine compose version!'
	exit 1
fi

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

	if ! fullVersion="$(grep $rcGrepV -E -- '-(rc|tp|beta)' <<<"$versionOptions" | tail -1)" || [ -z "$fullVersion" ]; then
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

	echo "$version: $fullVersion (buildx $buildxVersion, compose $composeVersion)"

	export fullVersion dindLatest
	doc="$(
		jq -nc --argjson buildx "$buildx" --argjson compose "$compose" '{
			version: env.fullVersion,
			arches: {},
			dindCommit: env.dindLatest,
			buildx: $buildx,
			compose: $compose,
		}'
	)"

	hasWindows=
	for bashbrewArch in "${!dockerArches[@]}"; do
		arch="${dockerArches[$bashbrewArch]}"
		# check whether the given architecture is supported for this release
		case "$bashbrewArch" in
			windows-*) url="https://download.docker.com/win/static/$channel/$arch/docker-$fullVersion.zip"; windows=1 ;;
			*) url="https://download.docker.com/linux/static/$channel/$arch/docker-$fullVersion.tgz"; windows= ;;
		esac
		if wget --quiet --spider "$url" &> /dev/null; then
			export bashbrewArch url
			doc="$(
				jq <<<"$doc" -c '.arches[env.bashbrewArch] = {
					dockerUrl: env.url,
				}'
			)"
		else
			continue
		fi

		if [ -n "$windows" ]; then
			hasWindows=1
			continue # Windows doesn't have rootless extras :)
		fi

		# https://github.com/moby/moby/blob/v20.10.7/hack/make/binary-daemon#L24
		# "vpnkit is available for x86_64 and aarch64"
		case "$bashbrewArch" in
			amd64 | arm64v8)
				rootlessExtrasUrl="https://download.docker.com/linux/static/$channel/$arch/docker-rootless-extras-$fullVersion.tgz"
				if wget --quiet --spider "$rootlessExtrasUrl" &> /dev/null; then
					export rootlessExtrasUrl
					doc="$(jq <<<"$doc" -c '
						.arches[env.bashbrewArch].rootlessExtrasUrl = env.rootlessExtrasUrl
					')"
				fi
				;;
		esac
	done

	# order here controls the order of the library/ file
	for variant in \
		cli \
		dind \
		dind-rootless \
		git \
		windows/windowsservercore-ltsc2022 \
		windows/windowsservercore-1809 \
	; do
		base="${variant%%/*}" # "buster", "windows", etc.
		if [ "$base" = 'windows' ] && [ -z "$hasWindows" ]; then
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
