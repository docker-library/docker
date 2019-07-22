#!/bin/sh
set -eu

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- docker "$@"
fi

# if our command is a valid Docker subcommand, let's invoke it through Docker instead
# (this allows for "docker run docker ps", etc)
if docker help "$1" > /dev/null 2>&1; then
	set -- docker "$@"
fi

_should_tls() {
	[ -n "${DOCKER_TLS_CERTDIR:-}" ] \
	&& [ -s "$DOCKER_TLS_CERTDIR/client/ca.pem" ] \
	&& [ -s "$DOCKER_TLS_CERTDIR/client/cert.pem" ] \
	&& [ -s "$DOCKER_TLS_CERTDIR/client/key.pem" ]
}

# if DOCKER_HOST isn't set and we don't have the default unix socket, let's set DOCKER_HOST to a sane remote value
if [ -z "${DOCKER_HOST:-}" ] && [ ! -S /var/run/docker.sock ]; then
	if _should_tls || [ -n "${DOCKER_TLS_VERIFY:-}" ]; then
		export DOCKER_HOST='tcp://docker:2376'
	else
		export DOCKER_HOST='tcp://docker:2375'
	fi
fi
if [ -n "${DOCKER_HOST:-}" ] && _should_tls; then
	export DOCKER_TLS_VERIFY=1
	export DOCKER_CERT_PATH="$DOCKER_TLS_CERTDIR/client"
fi

if [ "$1" = 'dockerd' ]; then
	cat >&2 <<-'EOW'

		📎 Hey there!  It looks like you're trying to run a Docker daemon.

		   You probably should use the "dind" image variant instead, something like:

		     docker run --privileged --name some-docker ... docker:dind ...

		   See https://hub.docker.com/_/docker/ for more documentation and usage examples.

	EOW
	sleep 3
fi

exec "$@"
