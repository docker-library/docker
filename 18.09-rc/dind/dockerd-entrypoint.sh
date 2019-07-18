#!/bin/sh
set -eu

# no arguments passed
# or first arg is `-f` or `--some-option`
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
	# add our default arguments
	if [ -n "${DOCKER_TLS_CERTDIR:-}" ] \
		&& tls-generate-certs.sh "$DOCKER_TLS_CERTDIR" \
		&& [ -s "$DOCKER_TLS_CERTDIR/server/ca.pem" ] \
		&& [ -s "$DOCKER_TLS_CERTDIR/server/cert.pem" ] \
		&& [ -s "$DOCKER_TLS_CERTDIR/server/key.pem" ] \
	; then
		# generate certs and use TLS if requested/possible (default in 19.03+)
		set -- dockerd \
			--host=unix:///var/run/docker.sock \
			--host=tcp://0.0.0.0:2376 \
			--tlsverify \
			--tlscacert "$DOCKER_TLS_CERTDIR/server/ca.pem" \
			--tlscert "$DOCKER_TLS_CERTDIR/server/cert.pem" \
			--tlskey "$DOCKER_TLS_CERTDIR/server/key.pem" \
			"$@"
	else
		# TLS disabled (-e DOCKER_TLS_CERTDIR='') or missing certs
		set -- dockerd \
			--host=unix:///var/run/docker.sock \
			--host=tcp://0.0.0.0:2375 \
			"$@"
	fi
fi

if [ "$1" = 'dockerd' ]; then
	if [ -x '/usr/local/bin/dind' ]; then
		# if we have the (mostly defunct now) Docker-in-Docker wrapper script, use it
		set -- '/usr/local/bin/dind' "$@"
	fi

	# explicitly remove Docker's default PID file to ensure that it can start properly if it was stopped uncleanly (and thus didn't clean up the PID file)
	find /run /var/run -iname 'docker*.pid' -delete
fi

exec "$@"
