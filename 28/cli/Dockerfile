#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.21

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

ENV DOCKER_VERSION 28.0.0

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-28.0.0.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-28.0.0.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-28.0.0.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-28.0.0.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.21.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.0/buildx-v0.21.0.linux-amd64'; \
			sha256='90f154aff1b1b0010ca3e59f473a59a86b5fdf34ca1196829c622c4fbf5e92fe'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.21.0/buildx-v0.21.0.linux-arm-v6'; \
			sha256='1a55ed189ee5c58b3d78459cf81d023a135a759c5ea3b7d1e2ad587cdfabac15'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.21.0/buildx-v0.21.0.linux-arm-v7'; \
			sha256='542676a5aa32ecfcfcb27c56a0c8d91af42614ed5c0266e91ed0b55d90a15555'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.0/buildx-v0.21.0.linux-arm64'; \
			sha256='5543113b559ca523726c8979defa24466e451dbfa6ffe42c278d22a3f76a327a'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.21.0/buildx-v0.21.0.linux-ppc64le'; \
			sha256='90c2748b59d0588cbd006e209ce8cecf202319213eba6542d01a5ce2f5c06f6e'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.0/buildx-v0.21.0.linux-riscv64'; \
			sha256='84148bbc57023004b186bf1ba618f987d9df51d3b588876bfc04f7a592fb9bc0'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.21.0/buildx-v0.21.0.linux-s390x'; \
			sha256='541b0fe136f003db4e0e5e4e3ec4ae00a647b50d398e7f63201d1ea712218132'; \
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

ENV DOCKER_COMPOSE_VERSION 2.33.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-x86_64'; \
			sha256='6395dbb256db6ea28d5c6695bc9bc33866c07ad1c93792f8d85857f1c21c34ee'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-armv6'; \
			sha256='360976f92dbf4b575bb9beb2737952709c685d1441eebd90c7eeb63225a44ada'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-armv7'; \
			sha256='69c5e0b8764876ef7521b4274eba470d0d6686d3def74e2ba0c216bf2bf6f077'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-aarch64'; \
			sha256='03a42a0fc0614ffc3c9ebca521cab75e02c427b68e45e3f6867d9510b9a28818'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-ppc64le'; \
			sha256='3e1c3ba91bbf27c0966ad384a96dbecb867c2cbda4fde929165ca35b99075023'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-riscv64'; \
			sha256='dffcdfbc88189a97c0000d1995476fa6712396d1472d6fbe24bfb424f46da7c3'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.33.0/docker-compose-linux-s390x'; \
			sha256='3f809fd846e3e38bc3dcb88546f88141a68e1bb4578a74c71ed5b563f95a45bb'; \
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
