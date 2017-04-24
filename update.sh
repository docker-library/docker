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

	dir="$version"
	[ -d "$dir" ] || continue

	if [ "$rcVersion" != "$version" ]; then
		bucket='test.docker.com'
	else
		bucket='get.docker.com'
	fi

	(
		set -x
		#s/^(ENV DIND_COMMIT) .*/\1 '"$dindLatest"'/; # TODO once "Supported Docker versions" minimums at Docker 1.8+ (1.6 at time of this writing), bring this back again
		sed -ri \
			-e 's/^(ENV DOCKER_BUCKET) .*/\1 '"$bucket"'/' \
			-e 's/^(ENV DOCKER_VERSION) .*/\1 '"$fullVersion"'/' \
			-e 's/^(FROM docker):.*/\1:'"$version"'/' \
			"$dir"/{,git/,dind/}Dockerfile
	)

	for arch in \
		x86_64 \
		armel \
	; do
		url="https://$bucket/builds/Linux/$arch/docker-$fullVersion.tgz.sha256"
		sha256="$(curl -fsSL "$url" | cut -d' ' -f1)"
		(
			set -x
			sed -ri 's!^(ENV DOCKER_SHA256_'"$arch"') .*!\1 '"$sha256"'!' "$dir/Dockerfile"
		)
	done

	travisEnv='\n  - VERSION='"$version$travisEnv"
done

travis="$(awk -v 'RS=\n\n' '$1 == "env:" { $0 = "env:'"$travisEnv"'" } { printf "%s%s", $0, RS }' .travis.yml)"
echo "$travis" > .travis.yml
