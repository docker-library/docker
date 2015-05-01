#!/bin/bash
set -e

bucket="${1:-get.docker.com}"

current="$(curl -fsSL "https://${bucket}/latest")"
sha256="$(curl -fsSL "http://${bucket}/builds/Linux/x86_64/docker-${current}.sha256" | cut -d' ' -f1)"

# "tac|tac" for http://stackoverflow.com/a/28879552/433558
dindLatest="$(curl -sSL 'https://github.com/docker/docker/commits/master/hack/dind.atom'| tac|tac | awk -F '[[:space:]]*[<>/]+' '$2 == "id" && $3 ~ /Commit/ { print $4; exit }')"

(
	set -x

	sed -ri '
		s/^(ENV DOCKER_BUCKET) .*/\1 '"$bucket"'/;
		s/^(ENV DOCKER_VERSION) .*/\1 '"$current"'/;
		s/^(ENV DOCKER_SHA256) .*/\1 '"$sha256"'/;

		s/^(ENV DIND_COMMIT) .*/\1 '"$dindLatest"'/;
	' {,dind/}Dockerfile
)
