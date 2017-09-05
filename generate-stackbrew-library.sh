#!/bin/bash
set -eu

declare -A aliases=(
	# https://blog.docker.com/2017/03/docker-enterprise-edition/
	[17.06]='stable'
	[17.07]='17 edge latest'
	[17.08-rc]='rc test'
)

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
	while [ "$fullVersion" != "$rcVersion" -a "${fullVersion%[.-]*}" != "$fullVersion" ]; do
		versionAliases+=( $fullVersion )
		fullVersion="${fullVersion%[.-]*}"
	done
	versionAliases+=(
		$version
		${aliases[$version]:-}
	)

	versionArches="$(versionArches "$version")"

	echo
	cat <<-EOE
		Tags: $(join ', ' "${versionAliases[@]}")
		Architectures: $(join ', ' $versionArches)
		GitCommit: $commit
		Directory: $version
	EOE

	for variant in \
		dind git \
	; do
		[ -f "$version/$variant/Dockerfile" ] || continue

		commit="$(dirCommit "$version/$variant")"

		slash='/'
		variantAliases=( "${versionAliases[@]/%/-${variant//$slash/-}}" )
		variantAliases=( "${variantAliases[@]//latest-/}" )

		echo
		cat <<-EOE
			Tags: $(join ', ' "${variantAliases[@]}")
			Architectures: $(join ', ' $versionArches)
			GitCommit: $commit
			Directory: $version/$variant
		EOE
	done
done
