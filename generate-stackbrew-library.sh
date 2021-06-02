#!/bin/bash
set -eu

self="$(basename "$BASH_SOURCE")"
cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

if [ "$#" -eq 0 ]; then
	versions="$(jq -r 'keys | map(@sh) | join(" ")' versions.json)"
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
	parent="$(awk 'toupper($1) == "FROM" { print $2 }' "$version/Dockerfile")"
	parentArches="${parentRepoToArches[$parent]:-}"

	comm -12 \
		<(
			version="$version" jq -r '
				.[env.version].arches | to_entries[]
				| select(.value.'"$selector"')
				| .key
			' versions.json | sort
		) \
		<(xargs -n1 <<<"$parentArches" | sort)
}

# sort version numbers with highest first
IFS=$'\n'; set -- $(sort -rV <<<"$*"); unset IFS

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

	fullVersion="$(jq -r '.[env.version].version' versions.json)"

	if [ "$rcVersion" != "$version" ] && [ -e "$rcVersion/Dockerfile" ]; then
		# if this is a "-rc" release, let's make sure the release it contains isn't already GA (and thus something we should not publish anymore)
		export rcVersion
		rcFullVersion="$(jq -r '.[env.rcVersion].version' versions.json)"
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

	variants="$(jq -r '.[env.version].variants | map(@sh) | join(" ")' versions.json)"
	eval "variants=( $variants )"

	for v in "${variants[@]}"; do
		dir="$version${v:+/$v}"
		[ -f "$dir/Dockerfile" ] || continue

		commit="$(dirCommit "$dir")"

		variant="$(basename "$v")"
		variantAliases=( "${versionAliases[@]/%/${variant:+-$variant}}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

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
