#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

url='git://github.com/docker-library/docker'

echo '# maintainer: InfoSiftr <github@infosiftr.com> (@infosiftr)'

commit="$(git log -1 --format='format:%H' -- .)"
fullVersion="$(grep -m1 'ENV DOCKER_VERSION ' Dockerfile | cut -d' ' -f3)"

versionAliases=()
while [ "${fullVersion%[.-]*}" != "$fullVersion" ]; do
	versionAliases+=( $fullVersion )
	fullVersion="${fullVersion%[.-]*}"
done
versionAliases+=( $fullVersion latest )

echo
for va in "${versionAliases[@]}"; do
	echo "$va: ${url}@${commit}"
done

echo
echo '# "supported": one tag per major, only upstream-supported majors (which is currently only "latest")'
