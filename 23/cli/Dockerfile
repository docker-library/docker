#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18

RUN apk add --no-cache \
		ca-certificates \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client

# ensure that nsswitch.conf is set up for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/moby/moby/blob/v20.10.21/hack/make.sh#L115
# - https://github.com/golang/go/blob/go1.19.3/src/net/conf.go#L227-L303
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf

ENV DOCKER_VERSION 23.0.6

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-23.0.6.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-23.0.6.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-23.0.6.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-23.0.6.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.11.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.1/buildx-v0.11.1.linux-amd64'; \
			sha256='34927047282ef9052f57809fe94783b2dc0ab556fdd60c2c0b7f4e6e5f05a53b'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.11.1/buildx-v0.11.1.linux-arm-v6'; \
			sha256='ec7b60a4946c7c0fdaa3a44590adc08a0ead0ecca860358c57ca62d3e9a3a0be'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.11.1/buildx-v0.11.1.linux-arm-v7'; \
			sha256='d122ec20622a744419fea021fd4850edc56d816b5cbc746d1f90184dbc227fec'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.1/buildx-v0.11.1.linux-arm64'; \
			sha256='1649de43c6477eb8bf615f0817932e69e500ce530422bed47c9f3a689baeb788'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.11.1/buildx-v0.11.1.linux-ppc64le'; \
			sha256='78cfc6cdb3982770ce4e922e62c42ee0750b4b2837349661d20834356f004d16'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.1/buildx-v0.11.1.linux-riscv64'; \
			sha256='1d932a0925e9aee66c85cb7a351e9dbd210294ccb8d01208bf953108ad321f4d'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.11.1/buildx-v0.11.1.linux-s390x'; \
			sha256='89466f278264f597d3c81e5230ab5795b2578ad62d2c7e8f8be398546e02c3d7'; \
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

ENV DOCKER_COMPOSE_VERSION 2.20.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-x86_64'; \
			sha256='b49e358d11c198fa228fb7eca2a177affd8e1e33e06d29940668668482f797cd'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-armv6'; \
			sha256='72a0362081a268eb2410a4e57ec0df466ff2eb34e38ffb5552f9a6e58213758d'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-armv7'; \
			sha256='a5f181e83a78f5ab8c202f99713bc745712acbf387d9d2ce687c76e1ccdb36e2'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-aarch64'; \
			sha256='f82c5bc86cb0937628ae616087224aa7d02372d50e638eca646d5834c6766ee7'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-ppc64le'; \
			sha256='2a8e638362cd3dc1f739b49066cf9f4d0d21e6e46f082d359c82c7d0c8081eee'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-riscv64'; \
			sha256='5e5c89c6ce73d0f4aa1d01542fc287c97880d0ecb1766162c34b3a7b2852a50f'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-linux-s390x'; \
			sha256='d58d6545d9d88f24a495199e4a438cf10351416b7655acda334e0e9e8448177c'; \
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
