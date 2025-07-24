#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.22

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

ENV DOCKER_VERSION 28.3.2

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-28.3.2.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-28.3.2.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-28.3.2.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-28.3.2.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.26.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-amd64'; \
			sha256='9451034b6ca5354e8bf88a2002a413aedabf110fd0f12ebb0b2f2cc241be8e41'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-arm-v6'; \
			sha256='e9f89ed92231e937b380afc8f0105dc57e1fd5a3949a1545e863312706bf2947'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-arm-v7'; \
			sha256='92fe156e22eabbb58fb6b44aa3c59c2c06a820b66913158ed209ef5e18abc356'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-arm64'; \
			sha256='b610d3c24836b2e7fecab5ef2c9466239a0f0156993a0406ea58943b87bff918'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-ppc64le'; \
			sha256='74a9c8856ef7e742b5193358b43c8dbea9dc739009e4894c840fdb0a9c746d0d'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-riscv64'; \
			sha256='698496a08f9c008230e858c63590aeb44b4806df2d6f02cd0b382137ce9394c6'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.26.1/buildx-v0.26.1.linux-s390x'; \
			sha256='6b561cb99d105114484897a3bc3f105dead11d4c14f28ffbf0873ce7fd1fe2d6'; \
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

ENV DOCKER_COMPOSE_VERSION 2.39.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-x86_64'; \
			sha256='a5ea28722d5da628b59226626f7d6c33c89a7ed19e39f750645925242044c9d2'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-armv6'; \
			sha256='14a8a2fd5ca75cf87a9c33f79eea5b51701d3a2039387ae48440c9d78b2c83c2'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-armv7'; \
			sha256='a97c785b148cf744e4f91835fa981dc93d6ced5132d42dab934947e33032af98'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-aarch64'; \
			sha256='7b2627ed76f7dcb0d93f649f185af912372229b4c09762a3cd1db5be5255632b'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-ppc64le'; \
			sha256='a2c76f4ea8cbba5906cfe9e97fc67463ad954813dfbddf341bf5062c5c0c93ec'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-riscv64'; \
			sha256='3e54325b4019398e058be3cd8589b9ecc98a1a97b7fe8f3280ee4e25281091e2'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-s390x'; \
			sha256='87e75c7ffd019507c823c49d83fac62eda239e55544bb56d7707c817f52acc69'; \
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
