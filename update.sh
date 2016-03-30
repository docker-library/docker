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

dockerVersions="$(git ls-remote --tags https://github.com/docker/docker.git | cut -d$'\t' -f2 | grep '^refs/tags/v[0-9].*$' | sed 's!^refs/tags/v!!; s!\^{}$!!' | sort -ruV)"

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
	bucket='get.docker.com'
	if [ "$rcVersion" != "$version" ]; then
		bucket='test.docker.com'
	fi
	case "$rcVersion" in
		1.9|1.10)
			artifact="https://$bucket/builds/Linux/x86_64/docker-$fullVersion"
			;;
		*)
			artifact="https://$bucket/builds/Linux/x86_64/docker-$fullVersion.tgz"
			;;
	esac
	sha256="$(curl -fsSL "$artifact.sha256" | cut -d' ' -f1)" || true
	(
		set -x
		sed -ri '
			s/^(ENV DOCKER_BUCKET) .*/\1 '"$bucket"'/;
			s/^(ENV DOCKER_VERSION) .*/\1 '"$fullVersion"'/;
			s/^(ENV DOCKER_SHA256) .*/\1 '"$sha256"'/;
			#s/^(ENV DIND_COMMIT) .*/\1 '"$dindLatest"'/; # TODO once "Supported Docker versions" minimums at Docker 1.8+ (1.6 at time of this writing), bring this back again
			s/^(FROM docker):.*/\1:'"$version"'/;
		' "$version/Dockerfile" "$version"/*/Dockerfile
	)
	
	travisEnv='\n  - VERSION='"$version$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
