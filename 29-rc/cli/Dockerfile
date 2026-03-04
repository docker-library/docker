#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.23

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

ENV DOCKER_VERSION 29.3.0-rc.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-29.3.0-rc.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-29.3.0-rc.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-29.3.0-rc.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-29.3.0-rc.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.32.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.32.0/buildx-v0.32.0.linux-amd64'; \
			sha256='1cdd7b29429bb97796ce9b76330412aa1e6f8627b9b12a4c53d556f6fee59c93'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.32.0/buildx-v0.32.0.linux-arm-v6'; \
			sha256='e8ec8bcf196bc216bea143c881fe901e5528bc702f2df0ecbf5e2c5e34ceeb8c'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.32.0/buildx-v0.32.0.linux-arm-v7'; \
			sha256='2c0b2c1620cf2be32e50f400e158fb990d79ac89874424efcc84ec9f42d62d94'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.32.0/buildx-v0.32.0.linux-arm64'; \
			sha256='cd0690b2d1b91ec9b799c34340e4ca8456845f5c053ef38775388290369aace1'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.32.0/buildx-v0.32.0.linux-ppc64le'; \
			sha256='d789a313105446d4e2d6c6960c30afa77d6ee045439add094cb473dcfa82080f'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.32.0/buildx-v0.32.0.linux-riscv64'; \
			sha256='04807647bb98c447ea6c886ed492219e7b4f0ecce9deaf10ed5b023eef2cd7d9'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.32.0/buildx-v0.32.0.linux-s390x'; \
			sha256='0ac991909daa167894b2a9a9c775c1d66f8246835543c3eb86ec80d0f621788e'; \
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

ENV DOCKER_COMPOSE_VERSION 5.1.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.1.0/docker-compose-linux-x86_64'; \
			sha256='5633cb21e06a7c88c7ca48a9334d3d0f7f892e9605ae9e9a45f9a095d4ffceb8'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.1.0/docker-compose-linux-armv6'; \
			sha256='14159a5fde026633a7d436d6f61979351296a6c24921c009900ff6fb289dd097'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.1.0/docker-compose-linux-armv7'; \
			sha256='364a8f6d32daa9c4343c5335451af9b7f9531d9079f9621d6800c6c60eb438a1'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.1.0/docker-compose-linux-aarch64'; \
			sha256='da671ae15b4d7c68c38b572a2e9ceba89f09657d2682c2d2e34ad6db828e7442'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.1.0/docker-compose-linux-ppc64le'; \
			sha256='074fe8a082415c84d37a11c325808c2f4aa35e1ed3b15e3fd676feb85480ee59'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.1.0/docker-compose-linux-riscv64'; \
			sha256='f09c0fe479a22563ab70a87ff09611a0da66a02b29bc97926bbc926e6ea27cea'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.1.0/docker-compose-linux-s390x'; \
			sha256='6a5c638f7c3b2cacd87eda50af1b98474950d38ea094308a370c7fa3db10c47c'; \
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
