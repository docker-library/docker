#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.19

RUN apk add --no-cache \
		ca-certificates \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client

# ensure that nsswitch.conf is set up for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/moby/moby/blob/v24.0.6/hack/make.sh#L111
# - https://github.com/golang/go/blob/go1.19.13/src/net/conf.go#L227-L303
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf

# pre-add a "docker" group for socket usage
RUN set -eux; \
	addgroup -g 2375 -S docker

ENV DOCKER_VERSION 24.0.7

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-24.0.7.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-24.0.7.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-24.0.7.tgz'; \
			;; \
		*) echo >&2 "error: unsupported 'docker.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'docker.tgz' "$url"; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		--no-same-owner \
		'docker/docker' \
	; \
	rm docker.tgz; \
	\
	docker --version

ENV DOCKER_BUILDX_VERSION 0.12.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-amd64'; \
			sha256='716321df8ca9c82ffe96f37e9f4aa1199d4969795836dbd57ef72d12e3ac5085'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-arm-v6'; \
			sha256='4b3c78b59c0383ab21327e2902af2ea317e3b85e442b1cd776f0c2a7bbbb2999'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-arm-v7'; \
			sha256='fe0a9e7812051a72c47d009bf9373e76e23644cc3291c848ac4a9b6f237e9e75'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-arm64'; \
			sha256='fb72d627f2ee080bba70375c367f4292867821e29ca9a8cf485622f6ede8f436'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-ppc64le'; \
			sha256='1c649498d727183d82fb243e08856533ea90e8d63bfcd6f8b23b264dbcf7ea7a'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-riscv64'; \
			sha256='152e7b423c1ce888eb0a658321eb8c28cc1d09af01acd5c66eddf8474dddf55c'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.12.1/buildx-v0.12.1.linux-s390x'; \
			sha256='acee98a9f0550bf2c6c1161cf8067c031ddf0c566c41de7db27847bb72e8ee0b'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-buildx' architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-buildx' "$url"; \
	echo "$sha256 *"'docker-buildx' | sha256sum -c -; \
	\
	plugin='/usr/local/libexec/docker/cli-plugins/docker-buildx'; \
	mkdir -p "$(dirname "$plugin")"; \
	mv -vT 'docker-buildx' "$plugin"; \
	chmod +x "$plugin"; \
	\
	docker buildx version

ENV DOCKER_COMPOSE_VERSION 2.24.2
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-x86_64'; \
			sha256='067a12983b9333d01947329190af756b6d12afe7b4b51b3e1e29328b4afe3b9f'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-armv6'; \
			sha256='582d734ef0c14335ee4691f3550d56b3e1c1c4d787ed6354830b3c222eee542e'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-armv7'; \
			sha256='e83fa84dc73cc8d5a0fe2d1ad3ad61202050f033e6df9f3f4f7b3c2b59181006'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-aarch64'; \
			sha256='beafe762fedd06fe9885317c33f8b29b39c2354d6840a494a69b3c3a36919212'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-ppc64le'; \
			sha256='6be73d6597efc822eff3f9dd6abb56b72ada76f8a5f798b1df2dce5105f39257'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-riscv64'; \
			sha256='33a15fcef9d975aee4ed404779fae068264da6de8f2851ead85f9e1701302411'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.24.2/docker-compose-linux-s390x'; \
			sha256='0b62a8d7aad7ce81220a4d77aa4b17e443b888248c1da22bc808db1fcbf1e9ac'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-compose' architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-compose' "$url"; \
	echo "$sha256 *"'docker-compose' | sha256sum -c -; \
	\
	plugin='/usr/local/libexec/docker/cli-plugins/docker-compose'; \
	mkdir -p "$(dirname "$plugin")"; \
	mv -vT 'docker-compose' "$plugin"; \
	chmod +x "$plugin"; \
	\
	ln -sv "$plugin" /usr/local/bin/; \
	docker-compose --version; \
	docker compose version

COPY modprobe.sh /usr/local/bin/modprobe
COPY docker-entrypoint.sh /usr/local/bin/

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
