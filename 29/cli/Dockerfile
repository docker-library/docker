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

ENV DOCKER_VERSION 29.2.0

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.2.0.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.2.0.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.2.0.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.2.0.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.31.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.31.0/buildx-v0.31.0.linux-amd64'; \
			sha256='39cc424a730d8b7364c23a137582cb29e7f024b175bb595001ff6f90121b005b'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.31.0/buildx-v0.31.0.linux-arm-v6'; \
			sha256='fad601a520d9da32ff72d5f844c08318bb66db7a9c150e01541170e4e275a724'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.31.0/buildx-v0.31.0.linux-arm-v7'; \
			sha256='68f3aff3e29d9c013a90bec8cd841a86d57670394870fe0aaaceafcdd28f4071'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.31.0/buildx-v0.31.0.linux-arm64'; \
			sha256='3192d6deafed620132da1acd7c68499e163c814bc2be988a3eb2c5302764a30a'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.31.0/buildx-v0.31.0.linux-ppc64le'; \
			sha256='fe18282ceb82368e3b7fd79277e34d9904dfbfd0318a3c9fa2e4a2ab12f932e6'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.31.0/buildx-v0.31.0.linux-riscv64'; \
			sha256='bb01f095fb6b3734e352c4f58b7ef294f054d990c899fbfcaf5aa3fe1efbd83c'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.31.0/buildx-v0.31.0.linux-s390x'; \
			sha256='b03b64ab619c073edbaa310d83f275c52b7380abf080d35ea936696eab42aba1'; \
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

ENV DOCKER_COMPOSE_VERSION 5.0.2
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.0.2/docker-compose-linux-x86_64'; \
			sha256='2d880f723d3da7c779c54fdaea91a842fca8af55d1397f1ed8d7cbab3dd7af67'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.0.2/docker-compose-linux-armv6'; \
			sha256='6618f69bff2b9d2119164e4b44038e1b049c3cc9db39d49f8560db254b0a24b7'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.0.2/docker-compose-linux-armv7'; \
			sha256='d9a0742638f15bd91598ce465cca8718490d967cfb1a28305c388f214d09976b'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.0.2/docker-compose-linux-aarch64'; \
			sha256='ac7810e0cd56a5b58576688196fafa843e07e8241fb91018a736d549ea20a3f3'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.0.2/docker-compose-linux-ppc64le'; \
			sha256='1e7ff60971411ffba30208c24c6f0988f8589b9d7bf7783c42f229e95f0648c3'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.0.2/docker-compose-linux-riscv64'; \
			sha256='745cc32f394cd68bb4f09124c43d5d4532277859b6c92efab619722af6eac686'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.0.2/docker-compose-linux-s390x'; \
			sha256='d5a9fb6b035cf040fceecccca4892cf55f291e9bf1bb7dd5eb089923bc6e0aac'; \
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
