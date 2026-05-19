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

ENV DOCKER_VERSION 29.5.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.5.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.5.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.5.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.5.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.34.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.34.1/buildx-v0.34.1.linux-amd64'; \
			sha256='f1332ddb9010bd0b72628266c3a906d9a6979848033df4c8d9bd2cd113bae12b'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.34.1/buildx-v0.34.1.linux-arm-v6'; \
			sha256='1f6c8a082281706a0b9e24b64b9210ca0df5273ceaf600536012e7a62d790538'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.34.1/buildx-v0.34.1.linux-arm-v7'; \
			sha256='ad4e0938c94638ac882641b924f6eff6889cc59a11f062e733cf337458aa6f35'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.34.1/buildx-v0.34.1.linux-arm64'; \
			sha256='c34e32dd6ea2653d960d6c099c9f09b9077e4a37504d2d31e5066eccc3904231'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.34.1/buildx-v0.34.1.linux-ppc64le'; \
			sha256='a509dc17005a4eee3568336d9e2479642e53b31110e039a8f5b4e6079744d0e2'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.34.1/buildx-v0.34.1.linux-riscv64'; \
			sha256='c2cf15773a0610e6de34a04e9191b07915d0ea2afb381a37ac87f0dcb213b85a'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.34.1/buildx-v0.34.1.linux-s390x'; \
			sha256='edb0e83d5a2fa8913d0af46385b648408b4776ee3241b4c15f92fcadbc72b550'; \
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

ENV DOCKER_COMPOSE_VERSION 5.1.3
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.1.3/docker-compose-linux-x86_64'; \
			sha256='a0298760c9772d2c06888fc8703a487c94c3c3b0134adeef830742a2fc7647b4'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.1.3/docker-compose-linux-armv6'; \
			sha256='514fc01481017bf4ae55a3b1fe7d598ca49a930e346803648bd88dba9d4ae3da'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.1.3/docker-compose-linux-armv7'; \
			sha256='4c1ce6ad43c184934a1f76cd55d7231192492c487acbd13e96258ed10fd9e468'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.1.3/docker-compose-linux-aarch64'; \
			sha256='e8105a3e687ea7e0b0f81abe4bf9269c8a2801fb72c2b498b5ff2472bc54145f'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.1.3/docker-compose-linux-ppc64le'; \
			sha256='ceaa1a9f24ef471e6f9fc34b30d11dcb6d8021a9a283c5e7261521ef12951432'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.1.3/docker-compose-linux-riscv64'; \
			sha256='f4a01e52ab7b14bc88e0657f6c477274f151c7907cfe6a5362709f7bd4814c44'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.1.3/docker-compose-linux-s390x'; \
			sha256='552d11a594aa3d81b4b69a2abd2a5c2e699378038a8efaa8200c0b556be3451f'; \
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
