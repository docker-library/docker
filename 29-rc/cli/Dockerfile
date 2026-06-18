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

ENV DOCKER_VERSION 29.6.0-rc.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-29.6.0-rc.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-29.6.0-rc.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-29.6.0-rc.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-29.6.0-rc.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.35.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.35.0/buildx-v0.35.0.linux-amd64'; \
			sha256='d41ece72044243b4f58b343441ae37446d9c29a7d6b5e11c61847bbcf8f7dfda'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.35.0/buildx-v0.35.0.linux-arm-v6'; \
			sha256='5938b81dc6203361bb984e961fc0afbcdc2bf05c5a666ec093ea99e612de616c'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.35.0/buildx-v0.35.0.linux-arm-v7'; \
			sha256='e1fe67cbe2d5a7b242e5f732a9708e6abaa6d19d717e65bfbd1d13baa8669d1f'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.35.0/buildx-v0.35.0.linux-arm64'; \
			sha256='c4248d6cbc4a619a7e0b4609c11e509ad4ac0b475e1c64817c0ac20c5d90c766'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.35.0/buildx-v0.35.0.linux-ppc64le'; \
			sha256='bcee77464deb25cfd0b905d4d871b0aad1b1164d6bcdf8b2fd8b1adb1db021c3'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.35.0/buildx-v0.35.0.linux-riscv64'; \
			sha256='3ecaf173eb24402ba29e9d3b7ddac4bde259a3a54e98112077014918ab49f61f'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.35.0/buildx-v0.35.0.linux-s390x'; \
			sha256='ef1738f3c70166e968d1bca3f853dbc515a3aa7ffa82f1a2ded033a050cd3203'; \
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

ENV DOCKER_COMPOSE_VERSION 5.1.4
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.1.4/docker-compose-linux-x86_64'; \
			sha256='33b208d7e76639db742fae84b966cc01dacae58ca3fc4dabbc907045aefdf0c4'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.1.4/docker-compose-linux-armv6'; \
			sha256='38c8b500e75de30707024db9d135af979f4fdf6b9bae82b7a854b17eddad1205'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.1.4/docker-compose-linux-armv7'; \
			sha256='5cce4229012b8b18067fba078c9ec4e2a5dd47cb4cb3a0cc3d431f6fc429060f'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.1.4/docker-compose-linux-aarch64'; \
			sha256='d4fb48b72857810314d3ee77123c89954101844efa4788031221f4c370495946'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.1.4/docker-compose-linux-ppc64le'; \
			sha256='044a5a6eac8ba3b686e5ad74d529293372eb6d8553685738fe93ae6a6fd92790'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.1.4/docker-compose-linux-riscv64'; \
			sha256='03565cf8e16b3afa6fd6555d697b3237ea2d4dbd5547ab6835bc90fa7e5e00bb'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.1.4/docker-compose-linux-s390x'; \
			sha256='5bd0db672b07bb86272e84bbddd286f42fe9b84080e4d47ad3a91a84bd8c2c3d'; \
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
