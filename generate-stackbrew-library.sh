#!/bin/bash
set -eu

declare -A aliases=(
	#[18.06]='edge'
)

# used for auto-detecting the "latest" of each channel (for tagging it appropriately)
# https://blog.docker.com/2017/03/docker-enterprise-edition/
declare -A latestChannelRelease=()

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

source '.architectures-lib'

parentArches() {
	local version="$1"; shift # "17.06", etc

	local parent="$(awk 'toupper($1) == "FROM" { print $2 }' "$version/Dockerfile")"
	echo "${parentRepoToArches[$parent]:-}"
}
versionArches() {
	local version="$1"; shift

	local parentArches="$(parentArches "$version")"

	local versionArches=()
	for arch in $parentArches; do
		if hasBashbrewArch "$arch" && grep -qE "^# $arch\$" "$version/Dockerfile"; then
			versionArches+=( "$arch" )
		fi
	done
	echo "${versionArches[*]}"
}

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

	if [ "$rcVersion" != "$version" ] && [ -e "$rcVersion/Dockerfile" ]; then
		# if this is a "-rc" release, let's make sure the release it contains isn't already GA (and thus something we should not publish anymore)
		rcFullVersion="$(git show HEAD:"$rcVersion/Dockerfile" | awk '$1 == "ENV" && $2 == "DOCKER_VERSION" { print $3; exit }')"
		latestVersion="$({ echo "$fullVersion"; echo "$rcFullVersion"; } | sort -V | tail -1)"
		if [[ "$fullVersion" == "$rcFullVersion"* ]] || [ "$latestVersion" = "$rcFullVersion" ]; then
			# "x.y.z-rc1" == x.y.z*
			continue
		fi
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
		if [ "$rcVersion" = '19.03' ]; then versionAliases+=( "$channel" ); fi # 19.03 is the last release to include any "channel" aliases
		latestChannelRelease[$channel]="$version"
	fi
	# every release goes into the "test" channel, so the biggest numbered release wins (RC or not)
	if [ -z "${latestChannelRelease['test']:-}" ]; then
		if [ "$rcVersion" = '19.03' ]; then versionAliases+=( 'test' ); fi # 19.03 is the last release to include any "channel" aliases
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
		dind dind-rootless git \
		windows/windowsservercore-{ltsc2016,1709} \
	; do
		dir="$version/$v"
		[ -f "$dir/Dockerfile" ] || continue
		variant="$(basename "$v")"

		commit="$(dirCommit "$dir")"

		variantAliases=( "${versionAliases[@]/%/-$variant}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		case "$v" in
			# https://github.com/docker/docker-ce/blob/8fb3bb7b2210789a4471c017561c1b0de0b4f145/components/engine/hack/make/binary-daemon#L24
			# "vpnkit is amd64-only" ... for now??
			dind-rootless) variantArches='amd64' ;;

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
