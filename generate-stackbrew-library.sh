#!/usr/bin/env bash
set -Eeuo pipefail

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [ "$#" -eq 0 ]; then
	versions="$(jq -r '
		to_entries
		# sort version numbers with highest first
		| sort_by(.key | split("[.-]"; "") | map(try tonumber // .))
		| reverse
		| map(if .value then .key | @sh else empty end)
		| join(" ")
	' versions.json)"
	eval "set -- $versions"
fi

# get the most recent commit which modified any of "$@"
fileCommit() {
	git log -1 --format='format:%H' HEAD -- "$@"
}

# get the most recent commit which modified "$1/Dockerfile" or any file COPY'd from "$1/Dockerfile"
dirCommit() {
	local dir="$1"; shift
	(
		cd "$dir"
		fileCommit \
			Dockerfile \
			$(git show HEAD:./Dockerfile | awk '
				toupper($1) == "COPY" {
					for (i = 2; i < NF; i++) {
						print $i
					}
				}
			')
	)
}

getArches() {
	local repo="$1"; shift
	local officialImagesUrl='https://github.com/docker-library/official-images/raw/master/library/'

	eval "declare -A -g parentRepoToArches=( $(
		find -name 'Dockerfile' -exec awk '
				toupper($1) == "FROM" && $2 !~ /^('"$repo"'|scratch|.*\/.*)(:|$)/ {
					print "'"$officialImagesUrl"'" $2
				}
			' '{}' + \
			| sort -u \
			| xargs bashbrew cat --format '[{{ .RepoName }}:{{ .TagName }}]="{{ join " " .TagEntry.Architectures }}"'
	) )"
}
getArches 'docker'

versionArches() {
	local version="$1"; shift
	local variant="${1:-}"
	local selector='dockerUrl'
	if [[ "$variant" = *rootless ]]; then
		selector='rootlessExtrasUrl'
	fi

	if [[ "$variant" = windows/* ]]; then
		version="$version" jq -r '
			.[env.version].arches
			| keys[]
			| select(startswith("windows-"))
		' versions.json | sort
		return
	fi

	local parent parentArches
	parent="$(awk 'toupper($1) == "FROM" { print $2 }' "$version/cli/Dockerfile")"
	parentArches="${parentRepoToArches[$parent]:-}"

	comm -12 \
		<(
			version="$version" jq -r '
				.[env.version].arches | to_entries[]
				| select(.value.'"$selector"')
				| .key
				# all arm32 builds are broken:
				# https://github.com/docker-library/docker/issues/260
				| select(startswith("arm32") | not)
			' versions.json | sort
		) \
		<(xargs -n1 <<<"$parentArches" | sort)
}

cat <<-EOH
# this file is generated via https://github.com/docker-library/docker/blob/$(fileCommit "$self")/$self

Maintainers: Tianon Gravi <tianon@dockerproject.org> (@tianon),
             Joseph Ferguson <yosifkit@gmail.com> (@yosifkit)
GitRepo: https://github.com/docker-library/docker.git
EOH

# prints "$2$1$3$1...$N"
join() {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

# used for auto-detecting the "latest" of each channel (for tagging it appropriately)
# https://blog.docker.com/2017/03/docker-enterprise-edition/
declare -A latestChannelRelease=()

for version; do
	export version
	rcVersion="${version%-rc}"

	if ! fullVersion="$(jq -er '.[env.version] | if . then .version else empty end' versions.json)"; then
		# support running "generate-stackbrew-library.sh" on a singular "null" version ("20.10-rc" when the RC is older than the GA release, for example)
		continue
	fi

	versionAliases=()
	if [ "$version" = "$rcVersion" ]; then
		while [ "$fullVersion" != "$rcVersion" -a "${fullVersion%[.-]*}" != "$fullVersion" ]; do
			versionAliases+=( $fullVersion )
			fullVersion="${fullVersion%[.-]*}"
		done
	else
		versionAliases+=( $fullVersion )
	fi
	versionAliases+=(
		$version
	)

	# add a few channel/version-related aliases
	majorVersion="${version%%.*}"
	if [ "$version" != "$rcVersion" ] && [ -z "${latestChannelRelease['rc']:-}" ]; then
		versionAliases+=( 'rc' )
		latestChannelRelease['rc']="$version"
	fi
	if [ "$version" = "$rcVersion" ] && [ -z "${latestChannelRelease[$majorVersion]:-}" ]; then
		versionAliases+=( "$majorVersion" )
		latestChannelRelease["$majorVersion"]="$version"
	fi

	channel='stable'
	if [ "$rcVersion" != "$version" ]; then
		channel='test'
	fi
	# every release goes into the "test" channel, so the biggest numbered release wins (RC or not)
	if [ -z "${latestChannelRelease['test']:-}" ]; then
		latestChannelRelease['test']="$version"
	fi
	if [ "$version" = "$rcVersion" ] && [ -z "${latestChannelRelease['latest']:-}" ]; then
		versionAliases+=( 'latest' )
		latestChannelRelease['latest']="$version"
	fi

	variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

	case "$rcVersion" in
		20.10) latestVariant='cli' ;;
		*)     latestVariant='dind' ;;
	esac

	for v in "${variants[@]}"; do
		dir="$version/$v"
		[ -f "$dir/Dockerfile" ] || continue

		commit="$(dirCommit "$dir")"

		variant="$(basename "$v")"
		variantAliases=( "${versionAliases[@]/%/-$variant}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		if [ "$variant" = 'cli' ] || [ "$variant" = 'dind' ]; then
			parent="$(awk 'toupper($1) == "FROM" { print $2 }' "$version/cli/Dockerfile")"
			alpine="${parent#*:}" # "3.14"
			suiteAliases=( "${variantAliases[0]}" ) # only "X.Y.Z-foo"
			suiteAliases=( "${suiteAliases[@]/%/-alpine$alpine}" )
			suiteAliases=( "${suiteAliases[@]//latest-/}" )
			variantAliases+=( "${suiteAliases[@]}" )
			if [ "$variant" = "$latestVariant" ]; then
				# add "latest" aliases
				suiteAliases=( "${versionAliases[0]}" ) # only "X.Y.Z-foo"
				suiteAliases=( "${suiteAliases[@]/%/-alpine$alpine}" )
				suiteAliases=( "${suiteAliases[@]//latest-/}" )
				variantAliases+=( "${versionAliases[@]}" "${suiteAliases[@]}" )
			fi
		fi

		sharedTags=()
		if [[ "$variant" == windowsservercore* ]]; then
			sharedTags=( "${versionAliases[@]/%/-windowsservercore}" )
			sharedTags=( "${sharedTags[@]//latest-/}" )
		fi

		echo
		echo "Tags: $(join ', ' "${variantAliases[@]}")"
		if [ "${#sharedTags[@]}" -gt 0 ]; then
			echo "SharedTags: $(join ', ' "${sharedTags[@]}")"
		fi
		cat <<-EOE
			Architectures: $(join ', ' $(versionArches "$version" "$v"))
			GitCommit: $commit
			Directory: $dir
		EOE
		[ "$variant" = "$v" ] || echo "Constraints: $variant"
	done
done
