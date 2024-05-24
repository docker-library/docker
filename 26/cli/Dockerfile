#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.20

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

ENV DOCKER_VERSION 26.1.3

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-26.1.3.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-26.1.3.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-26.1.3.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-26.1.3.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.14.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-amd64'; \
			sha256='68e4f8895331ade982de8085a8c137b8af65f3ef95040b6c6113552243638508'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-arm-v6'; \
			sha256='afa9324a987d71891a8a55d33fa913e4464377c71e7cc84ba68a5d4c5e803f74'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-arm-v7'; \
			sha256='32f0f7d30e498c1461b97b2591e5ed348e69b6d864243a838db6d2e6dc08144d'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-arm64'; \
			sha256='82e776e50a84293c160e8c89c125b7a86295c7aa7f30751d6a7c051c171762c1'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-ppc64le'; \
			sha256='64b62a17df3b0cd5bf88a1bc3f83cd50ebd56b403c2ebf4668b5d697fd324bc0'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-riscv64'; \
			sha256='32042b4dba38724404a063ee9851ebea1c85b46ebbfb58e7350ece04975fdc9c'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.14.1/buildx-v0.14.1.linux-s390x'; \
			sha256='c273b1801cdb2c78079f9c33ecec266d5104973254e4e152d0205f14d7bf7bfc'; \
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

ENV DOCKER_COMPOSE_VERSION 2.27.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-x86_64'; \
			sha256='ddc876fe2a89d5b7ea455146b0975bfe52904eecba9b192193377d6f99d69ad9'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-armv6'; \
			sha256='5f244291153cdd7facfe5007aa37f393d139c245b870025b8e86ef88a8de2705'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-armv7'; \
			sha256='9dcfa9523dc912370417b7ccc3d81900bbb98dd9addbff0d218398bbe9078bbd'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-aarch64'; \
			sha256='16e93b9c2fc147d29ca1acbb8ceab6a50a0e26af777f43dc7a753cb883142617'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-ppc64le'; \
			sha256='f351bfdbb6bb9d18b33672ccba6dd31c53a3bd1b81f9e9052fc6d9125e7d5719'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-riscv64'; \
			sha256='9940bd7533bcbd087d5301b8348136bc8922aa75739e3e359d8367e2f6dd7005'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.27.1/docker-compose-linux-s390x'; \
			sha256='6f4b6bb51987b2f61b91cfe4017a8d162e86b82ba3ae074b99b06a1ebe4387ed'; \
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
