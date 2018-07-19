#!/bin/bash
set -eu

declare -A aliases=(
	[18.06]='edge'
)

# used for auto-detecting the "latest" of each channel (for tagging it appropriately)
# https://blog.docker.com/2017/03/docker-enterprise-edition/
declare -A latestChannelRelease=()

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

source '.architectures-lib'

versions=( */ )
versions=( "${versions[@]%/}" )

# sort version numbers with highest first
IFS=$'\n'; versions=( $(echo "${versions[*]}" | sort -rV) ); unset IFS

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

for version in "${versions[@]}"; do
	rcVersion="${version%-rc}"

	commit="$(dirCommit "$version")"

	fullVersion="$(git show "$commit":"$version/Dockerfile" | awk '$1 == "ENV" && $2 == "DOCKER_VERSION" { print $3; exit }')"

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
	channel="$(versionChannel "$version")"
	majorVersion="${version%%.*}"
	if [ "$version" != "$rcVersion" ] && [ -z "${latestChannelRelease['rc']:-}" ]; then
		versionAliases+=( 'rc' )
		latestChannelRelease['rc']="$version"
	fi
	if [ "$version" = "$rcVersion" ] && [ -z "${latestChannelRelease[$majorVersion]:-}" ]; then
		versionAliases+=( "$majorVersion" )
		latestChannelRelease["$majorVersion"]="$version"
	fi
	versionAliases+=(
		${aliases[$version]:-}
	)
	if [ -z "${latestChannelRelease[$channel]:-}" ]; then
		versionAliases+=( "$channel" )
		latestChannelRelease[$channel]="$version"
	fi
	# every release goes into the "test" channel, so the biggest numbered release wins (RC or not)
	if [ -z "${latestChannelRelease['test']:-}" ]; then
		versionAliases+=( 'test' )
		latestChannelRelease['test']="$version"
	fi
	if [ "$version" = "$rcVersion" ] && [ -z "${latestChannelRelease['latest']:-}" ]; then
		versionAliases+=( 'latest' )
		latestChannelRelease['latest']="$version"
	fi

	versionArches="$(versionArches "$version")"

	echo
	cat <<-EOE
		Tags: $(join ', ' "${versionAliases[@]}")
		Architectures: $(join ', ' $versionArches)
		GitCommit: $commit
		Directory: $version
	EOE

	for v in \
		dind git \
		windows/windowsservercore-{ltsc2016,1709} \
	; do
		dir="$version/$v"
		[ -f "$dir/Dockerfile" ] || continue
		variant="$(basename "$v")"

		commit="$(dirCommit "$dir")"

		variantAliases=( "${versionAliases[@]/%/-$variant}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		case "$v" in
			windows/*) variantArches='windows-amd64' ;;
			*)         variantArches="$versionArches" ;;
		esac

		sharedTags=()
		if [[ "$variant" == 'windowsservercore'* ]]; then
			sharedTags=( "${versionAliases[@]/%/-windowsservercore}" )
			sharedTags=( "${sharedTags[@]//latest-/}" )
		fi

		echo
		echo "Tags: $(join ', ' "${variantAliases[@]}")"
		if [ "${#sharedTags[@]}" -gt 0 ]; then
			echo "SharedTags: $(join ', ' "${sharedTags[@]}")"
		fi
		cat <<-EOE
			Architectures: $(join ', ' $variantArches)
			GitCommit: $commit
			Directory: $dir
		EOE
		[ "$variant" = "$v" ] || echo "Constraints: $variant"
	done
done
