#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.24

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

ENV DOCKER_VERSION 29.8.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.8.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.8.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.8.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.8.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.37.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.37.1/buildx-v0.37.1.linux-amd64'; \
			sha256='9447199cdb435f25880548343c128a4b6650e8891ee598905d8d29d39a8e359b'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.37.1/buildx-v0.37.1.linux-arm-v6'; \
			sha256='3264d18a218bdc7107477f69dec6a303cbdf4a3454f402c60a14084b89ce3251'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.37.1/buildx-v0.37.1.linux-arm-v7'; \
			sha256='9ce373553b2ea4ef6bc8e5b33e7586d14c2d8d91539d3b96ac47ad0967a73843'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.37.1/buildx-v0.37.1.linux-arm64'; \
			sha256='e5cc9fe3bbff5cbc91230981f7860e06076110730a2db997082652199042a1f2'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.37.1/buildx-v0.37.1.linux-ppc64le'; \
			sha256='bd6bb13228a012d34d259c04de1a38c4f5c76485d9a2d15397794cde2634c3fe'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.37.1/buildx-v0.37.1.linux-riscv64'; \
			sha256='d23f968ff6dc1964ab172de280bd0de24c12f0f8131af76f69104d2f6de19cbd'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.37.1/buildx-v0.37.1.linux-s390x'; \
			sha256='7659b0d977e4a4376e360ea25d1dc626a3af7b34695bb272ec49b056bd303548'; \
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

ENV DOCKER_COMPOSE_VERSION 5.5.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.5.1/docker-compose-linux-x86_64'; \
			sha256='db1889184726840f75c4f9c001048430d4f25b3be3cb084d3ddd762bc0aed576'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.5.1/docker-compose-linux-armv6'; \
			sha256='421ff5910b09cb30842bff39e920091f3cec8da662e449d3935eb2f9593f6d12'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.5.1/docker-compose-linux-armv7'; \
			sha256='32e8e0182e7a94570ef60542e25346d465eaf5e2ca766d54bf9d64573ddaa52e'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.5.1/docker-compose-linux-aarch64'; \
			sha256='732e3a84c1a0f67256ce80bc2598a24546b10ca05f9faa97efceb1171ece2ef7'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.5.1/docker-compose-linux-ppc64le'; \
			sha256='1f49f2a3bbcf68260378486877be23e53ac6ca5dc4c03087b675e63de6dfedfc'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.5.1/docker-compose-linux-riscv64'; \
			sha256='d7a2af7fa8d9396cc62bfedb73496f3008cc2f2a0d3c20b67e956f89d9477366'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.5.1/docker-compose-linux-s390x'; \
			sha256='58c1395585a2a93ebf0b471c39cab597f46f4ce68884804a6d724431c85e82b9'; \
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
