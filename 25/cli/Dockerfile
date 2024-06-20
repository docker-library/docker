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

ENV DOCKER_VERSION 25.0.5

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-25.0.5.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-25.0.5.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-25.0.5.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-25.0.5.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.15.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.15.1/buildx-v0.15.1.linux-amd64'; \
			sha256='8d486f0088b7407a90ad675525ba4a17d0a537741b9b33fe3391a88cafa2dd0b'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.15.1/buildx-v0.15.1.linux-arm-v6'; \
			sha256='b4d1c41605b50b5549f1464461cfa72d010106bfb4606b45cc776daab4c25d7d'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.15.1/buildx-v0.15.1.linux-arm-v7'; \
			sha256='eabc32a4a86f943c3996eb2df5efd0d02d12603e356941ed46c132c64cbcbcdf'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.15.1/buildx-v0.15.1.linux-arm64'; \
			sha256='13f4ffd2b6922e941d6b6a9faee73ec9b8cab5b309ef90dfadf48142c2a47f34'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.15.1/buildx-v0.15.1.linux-ppc64le'; \
			sha256='6b41769526c9102d2352ed6900de33ee4be2eaf1927cfb216cc832c718e5c990'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.15.1/buildx-v0.15.1.linux-riscv64'; \
			sha256='52f5a974d8d1eb88d1defe0da5173d39df3608e554c3dcd1d45bde77c3d697f3'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.15.1/buildx-v0.15.1.linux-s390x'; \
			sha256='689c88555c42708ac812e3063590f8681b675d7f2ca68c024299ec388963615d'; \
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

ENV DOCKER_COMPOSE_VERSION 2.27.2
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-x86_64'; \
			sha256='6fbaf6e93ccc43078a71a12db1d38224725cb5a9675391c38510355073f24066'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-armv6'; \
			sha256='10b465c1771c262d372e24b09ed30fdc63687e35ae61c2365089e3998372a776'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-armv7'; \
			sha256='b5bd40dfadf089617fe9cacb7a08d6fd5fae28e2a465191be1f25f22ffead344'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-aarch64'; \
			sha256='de8c48203f4876fe3ae8bf27081a9aa69dc87de67a705f9d76c3a3ad776ed0c2'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-ppc64le'; \
			sha256='5810b3e6184032edbd21f12ed165ddecc823b8222ff5e4f6c55112af6f617c6d'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-riscv64'; \
			sha256='2c138daa9eaa909434c808018c4ab748a5f25caee16e3a7810fbeb3897b40878'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.27.2/docker-compose-linux-s390x'; \
			sha256='4084bdab8782e98c57a5f7aa7384699490048ce117dc7e70cad183702cc1645b'; \
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
