#!/bin/bash
set -e

declare -A aliases
aliases=(
	[1.7]='1 latest'
	[1.8-rc]='rc'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( */ )
versions=( "${versions[@]%/}" )
url='git://github.com/docker-library/docker'

echo '# maintainer: Tianon Gravi <tianon@dockerproject.org> (@tianon)'
echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

for (( i = ${#versions[@]} - 1; i >= 0; --i )); do
	version="${versions[$i]}"
	
	commit="$(git log -1 --format='format:%H' -- "$version")"
	fullVersion="$(grep -m1 'ENV DOCKER_VERSION ' "$version/Dockerfile" | cut -d' ' -f3)"
	versionAliases=( $fullVersion $version ${aliases[$version]} )
	
	echo
	for va in "${versionAliases[@]}"; do
		echo "$va: ${url}@${commit} $version"
	done
	
	for variant in dind git; do
		[ -f "$version/$variant/Dockerfile" ] || continue
		commit="$(git log -1 --format='format:%H' -- "$version/$variant")"
		echo
		for va in "${versionAliases[@]}"; do
			if [ "$va" = 'latest' ]; then
				va="$variant"
			else
				va="$va-$variant"
			fi
			echo "$va: ${url}@${commit} $version/$variant"
		done
	done
done
