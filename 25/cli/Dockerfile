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

ENV DOCKER_BUILDX_VERSION 0.16.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-amd64'; \
			sha256='9a9a6ca0b929a57db01020fb226b1a2ea2bc57eba63d4adec46c43d0009506e2'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-arm-v6'; \
			sha256='902f1240a6071c721f9746f0ff0859ef7b7368b683e322c08a1daa92d61d698a'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-arm-v7'; \
			sha256='81d53f05d1d02306844f5a364cae6d7ad24451497c171ee29e1c000a78f30c5c'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-arm64'; \
			sha256='1aa8f0438866c706654a6dd96e211e509d42b16b1a0e66c1777c95edb2f14f49'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-ppc64le'; \
			sha256='569f4a47bca797385eccac18e14e1d4bb681e35eeff6304c432de5bcd543120d'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-riscv64'; \
			sha256='e0cfc5072a792088115560e77a8540c9bf8299716984d42adc0735161472f076'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-s390x'; \
			sha256='80ff8dcddbc3d0306e5cb819eddf89ce970ea1dbf806eb0adf7b6cd616d1da63'; \
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

ENV DOCKER_COMPOSE_VERSION 2.28.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-x86_64'; \
			sha256='5b480d4f9e3517b375f0fbb781b39c63cec934f44b13c43b8f1d0f22bf6de8c3'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-armv6'; \
			sha256='ff366f16854e8febcdce21b750f6462abdcaa16209be490feaa8c2dd88b7884c'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-armv7'; \
			sha256='d829c0d3f85885ee29fcaf19d2b6001215820ad874a0b9cdc3172965acb80c50'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-aarch64'; \
			sha256='1ce6f9842b10ee5f61218a62f3acfc5839a31cd6daa6e87e926bef63dd9fee20'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-ppc64le'; \
			sha256='c02e6b718e94df66cd0a53349d6487dbc6da99aa582c0b9906637964ecd9bd15'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-riscv64'; \
			sha256='9d5d8033a8cf3deb05c7a9ee7cdf0086cc24a526fa9a10b4a778cc9124f5ef25'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.28.1/docker-compose-linux-s390x'; \
			sha256='c8ac20d8fac6d982a83e3b5bb34cda5ac326fbfde9b43c64a290258a1d7fbb38'; \
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
