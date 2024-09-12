#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.20

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

ENV DOCKER_VERSION 27.2.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-27.2.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-27.2.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-27.2.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-27.2.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.17.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.linux-amd64'; \
			sha256='6c65b3a80fd65312ed4949b76d10077c304ea013e78251a91cb0990562ee82a6'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.linux-arm-v6'; \
			sha256='e7236f91db70ab596cfa2ecd9f05c8231d18aa8da6fffd3439d69b5b04002e81'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.linux-arm-v7'; \
			sha256='e6950b2551f9930dd9894504da337a978c36052cb3517af63b4f65483364e70f'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.linux-arm64'; \
			sha256='8a971c4c9019f646fe9ac73c7e1cc3593a1246d43ddd9da24c588d1d93ca4c4e'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.linux-ppc64le'; \
			sha256='73fa298b089705b0420ae7cdd6f7859b9b2d0ab157d9dbfff70cffffe6f1e8a8'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.linux-riscv64'; \
			sha256='e7f5d0ac2d1c24d187e678f1bc40a55ef99bf04da7947d1901efa5bfeefc6869'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.17.0/buildx-v0.17.0.linux-s390x'; \
			sha256='1f97a8bc3bf91f0aded613adcf8115e8e9319f0d69dd912ba4712bd22dbd3f51'; \
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

ENV DOCKER_COMPOSE_VERSION 2.29.3
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.29.3/docker-compose-linux-x86_64'; \
			sha256='241b75fe0f8194a48d01f99d683aa1100579b21caa60d2d78c9c824855c57937'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.29.3/docker-compose-linux-armv6'; \
			sha256='4abff57472ce971e84ccd6d09287da02515e99e1a2208e867c5d03123a1c406d'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.29.3/docker-compose-linux-armv7'; \
			sha256='37fabd59e170943e12b4945a1a85c853e7db4759091f16036787fa02f6e2ec0a'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.29.3/docker-compose-linux-aarch64'; \
			sha256='10ded2b3b02b15957b1650b99d1e5ff216d882c5203a563d0aa7a87580a0d8ca'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.29.3/docker-compose-linux-ppc64le'; \
			sha256='f8c63bcc8e8dca6703893c6fe909a10aef288bc347ee37922afc0099abf87946'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.29.3/docker-compose-linux-riscv64'; \
			sha256='9e51a8531b0db7f96b1ef8c9c27f104b4847c867af72056d3f7625b065cf9861'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.29.3/docker-compose-linux-s390x'; \
			sha256='3929a9d8a6a7a2521de7c2b148337f04dd360e30a2114a8200b123b398e97c35'; \
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
