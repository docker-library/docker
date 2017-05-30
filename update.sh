#!/bin/bash
set -eo pipefail

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

# "tac|tac" for http://stackoverflow.com/a/28879552/433558
dindLatest="$(curl -fsSL 'https://github.com/docker/docker/commits/master/hack/dind.atom' | tac|tac | awk -F '[[:space:]]*[<>/]+' '$2 == "id" && $3 ~ /Commit/ { print $4; exit }')"

dockerVersions="$(
	{
		git ls-remote --tags https://github.com/docker/docker-ce.git
		git ls-remote --tags https://github.com/docker/docker.git # TODO remove-me (17.06+ live in docker-ce)
	} \
		| cut -d$'\t' -f2 \
		| grep '^refs/tags/v[0-9].*$' \
		| sed 's!^refs/tags/v!!; s!\^{}$!!' \
		| sort -ruV
)"

travisEnv=
for version in "${versions[@]}"; do
	rcGrepV='-v'
	rcVersion="${version%-rc}"
	if [ "$rcVersion" != "$version" ]; then
		rcGrepV=
	fi
	fullVersion="$(echo "$dockerVersions" | grep $rcGrepV -- '-rc' | grep "^$rcVersion[.]" | head -n1)"
	if [ -z "$fullVersion" ]; then
		echo >&2 "warning: cannot find full version for $version"
		continue
	fi

	channel='edge'
	if [ "$rcVersion" != "$version" ]; then
		channel='test'
	elif \
		minorVersion="${rcVersion##*.}" \
		&& minorVersion="${minorVersion#0}" \
		&& [ "$(( minorVersion % 3 ))" = '0' ] \
	; then
		channel='stable'
	fi

	(
		set -x
		#s/^(ENV DIND_COMMIT) .*/\1 '"$dindLatest"'/; # TODO once "Supported Docker versions" minimums at Docker 1.8+ (1.6 at time of this writing), bring this back again
		sed -ri \
			-e 's/^(ENV DOCKER_CHANNEL) .*/\1 '"$channel"'/' \
			-e 's/^(ENV DOCKER_VERSION) .*/\1 '"$fullVersion"'/' \
			-e 's/^(FROM docker):.*/\1:'"$version"'/' \
			"$version"/{,git/,dind/}Dockerfile
	)

	travisEnv='\n  - VERSION='"$version$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
