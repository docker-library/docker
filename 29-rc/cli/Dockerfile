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

ENV DOCKER_VERSION 29.10.0-rc.2

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-29.10.0-rc.2.tgz'; \
			sha256='f6960ea6a13bbac1a4bfdde08b13d937753d82dd083d8f29a5f855e4d157e1ee'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-29.10.0-rc.2.tgz'; \
			sha256='69caab6e31d38ab4a0bfc2161d7284ea54d69a6f7d92747f03018d761ffd89f7'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-29.10.0-rc.2.tgz'; \
			sha256='f0585679cc4214a6ba3c71a8def4386808de14e24b9d05f3a64e9e0107a7ae86'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-29.10.0-rc.2.tgz'; \
			sha256='cb4a05dd5a1f3f9812e7f2d122fdd8bea30cc182b98d9559a013573f2443474c'; \
			;; \
		'ppc64le') \
			url='https://download.docker.com/linux/static/test/ppc64le/docker-29.10.0-rc.2.tgz'; \
			sha256='b075ac18d0323a28e9189dcdbf1a8875803ff2cda55899041dddbed238ebbdfc'; \
			;; \
		's390x') \
			url='https://download.docker.com/linux/static/test/s390x/docker-29.10.0-rc.2.tgz'; \
			sha256='bf396b9a56b35e9bdc7c7b4eaa0049b4b4d9e82684e9317921763d5c4790cf1c'; \
			;; \
		*) echo >&2 "error: unsupported 'docker.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'docker.tgz' "$url"; \
	echo "$sha256 *"'docker.tgz' | sha256sum -c -; \
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

ENV DOCKER_BUILDX_VERSION 0.39.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-amd64'; \
			sha256='5fb31a097304fbf6dd4038649a0decf32c2b9510e4047acd7d68b9d700c46194'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-arm-v6'; \
			sha256='462b5699af263c05c5c1d973ab33f41810c263585d5b8b3dcfa6f7d3a11bc987'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-arm-v7'; \
			sha256='a49d315f68f6ed91b2ea88da4259b418abe015be68460e0eebe0b8d9f74970b1'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-arm64'; \
			sha256='722cdcdfdd6f3fb943fa1ba75102d057feb18ba72aab93b1b0a8cf2b2b48a25f'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-ppc64le'; \
			sha256='dd7b1f65b7432229a619d3b92ddbdd742fb26fa8b4a281a99489431ef5e041b7'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-riscv64'; \
			sha256='58d328fe5a8e58f4e5934913c1f7c51d6633f197d28f3114fe2cb9026cfb5d74'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-s390x'; \
			sha256='754f15a88f4496b5ddea3ac5626dd068f836965f799253a6402b07d324c45892'; \
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

ENV DOCKER_COMPOSE_VERSION 5.7.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.7.1/docker-compose-linux-x86_64'; \
			sha256='af426722a8af5de812fcee30cc1c39f0639f5f723cbadefb25e5d4db054064cf'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.7.1/docker-compose-linux-armv6'; \
			sha256='923137699688e7ea1aade66c16b9a1d475150487ccc99636d0f1de3ce46e6107'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.7.1/docker-compose-linux-armv7'; \
			sha256='c03e0c93cf747f311d39f6920a33c461fd0f7a6246439aaf259766527caa28f5'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.7.1/docker-compose-linux-aarch64'; \
			sha256='f2f49f903240895fa764c0dca3a14548b754ad9426f6b609ccaf55ec5a3aa2a5'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.7.1/docker-compose-linux-ppc64le'; \
			sha256='e41bf397abf7fc7a1cd35a039676067e6fc36d022a48847584db63cff0d9d196'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.7.1/docker-compose-linux-riscv64'; \
			sha256='29ba4c5fc8eb53e2fa2d0327c640c6a727086fd7efae79da47bf0a82bde290f3'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.7.1/docker-compose-linux-s390x'; \
			sha256='078f555e41e7c2d37d47f81cffd6b80d77288ba562bee19ac00215205edca278'; \
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
