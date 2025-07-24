#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.22

RUN apk add --no-cache \
		ca-certificates \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client \
# https://github.com/docker-library/docker/issues/482#issuecomment-2197116408
		git

# ensure that nsswitch.conf is set up for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/moby/moby/blob/v24.0.6/hack/make.sh#L111
# - https://github.com/golang/go/blob/go1.19.13/src/net/conf.go#L227-L303
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf

# pre-add a "docker" group for socket usage
RUN set -eux; \
	addgroup -g 2375 -S docker

ENV DOCKER_VERSION 28.3.2

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-28.3.2.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-28.3.2.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-28.3.2.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-28.3.2.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.26.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-amd64'; \
			sha256='9451034b6ca5354e8bf88a2002a413aedabf110fd0f12ebb0b2f2cc241be8e41'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-arm-v6'; \
			sha256='e9f89ed92231e937b380afc8f0105dc57e1fd5a3949a1545e863312706bf2947'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-arm-v7'; \
			sha256='92fe156e22eabbb58fb6b44aa3c59c2c06a820b66913158ed209ef5e18abc356'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-arm64'; \
			sha256='b610d3c24836b2e7fecab5ef2c9466239a0f0156993a0406ea58943b87bff918'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-ppc64le'; \
			sha256='74a9c8856ef7e742b5193358b43c8dbea9dc739009e4894c840fdb0a9c746d0d'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-riscv64'; \
			sha256='698496a08f9c008230e858c63590aeb44b4806df2d6f02cd0b382137ce9394c6'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-s390x'; \
			sha256='6b561cb99d105114484897a3bc3f105dead11d4c14f28ffbf0873ce7fd1fe2d6'; \
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

ENV DOCKER_COMPOSE_VERSION 2.39.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.39.0/docker-compose-linux-x86_64'; \
			sha256='56cad0ed632214fe3f77afd349a33e56fcec6e25f458210b8e9c6b9b33502a5a'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.39.0/docker-compose-linux-armv6'; \
			sha256='d54f81cd5ae68848287a954158855f0aeb2938e6a465498d1e1bc2a6f2d0834f'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.39.0/docker-compose-linux-armv7'; \
			sha256='ee9d71a8e953bed3fe34689a426eda615aea84642940038cdfdbdc76a8703dec'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.39.0/docker-compose-linux-aarch64'; \
			sha256='1d8780c5bdfcd7696861578f9c66d16dd603a4b8af31588c7c3ac4467f850756'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.39.0/docker-compose-linux-ppc64le'; \
			sha256='acbe2af3a0aba654dd870a6a5d0b42276d2f1b32d7a069e3d121ace2446eaed2'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.39.0/docker-compose-linux-riscv64'; \
			sha256='3e39c59e9534da95f983e46a5024e1cc6c37f31a94d5e46ece4a8e649628bbab'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.39.0/docker-compose-linux-s390x'; \
			sha256='eedb352c89a64eb48d814c63caf6c089c62466d839ce97b96865d44111e4efda'; \
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
