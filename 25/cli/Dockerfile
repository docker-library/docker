#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.19

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

ENV DOCKER_VERSION 25.0.4

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-25.0.4.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-25.0.4.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-25.0.4.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-25.0.4.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.13.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.13.1/buildx-v0.13.1.linux-amd64'; \
			sha256='3e2bc8ed25a9125d6aeec07df4e0211edea6288e075b524160ef3fd305d3d74c'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.13.1/buildx-v0.13.1.linux-arm-v6'; \
			sha256='643063c656098e312533fe5ee3411523fa06cc3926bd2e96b4c6239b9cecbf88'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.13.1/buildx-v0.13.1.linux-arm-v7'; \
			sha256='8d42e7823237e777b121070fda6ad68159539aa6597aedfa7630384643ad6f9a'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.13.1/buildx-v0.13.1.linux-arm64'; \
			sha256='3ba35a5d38361a64b62aeb9d20acc835ff6862a711cb438e610026b29c0ac489'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.13.1/buildx-v0.13.1.linux-ppc64le'; \
			sha256='1d16f7b15706d98523889a1ca50e9dfc44bbaec1f736d883a0528805795b9de2'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.13.1/buildx-v0.13.1.linux-riscv64'; \
			sha256='202221c9b7fb881d092986e8ec2497ee71729f17c4afd912384a086af700e1ad'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.13.1/buildx-v0.13.1.linux-s390x'; \
			sha256='71d7c39192b1b07790eb71e46742cc69a559f3eb00a1512f4a8d2ea1067408da'; \
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

ENV DOCKER_COMPOSE_VERSION 2.24.7
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-x86_64'; \
			sha256='19c9deb6f4d3915f5c93441b8d2da751a09af82df62d55eab097c2cbfebd519f'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-armv6'; \
			sha256='c9fb575152f757a5edcce8ca0a399de6ba8dfacd80a8c730f56f0957cadb5858'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-armv7'; \
			sha256='72ec3b7726b5784cf4ac14e2c32781f5090cb57a2951cfc59b24a74a88e9ce79'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-aarch64'; \
			sha256='86fa6982c55e1bb741ac71ebbbb78c715224eeb46a820364ec6075cf87047d53'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-ppc64le'; \
			sha256='236176989b202caebce42629d57f6faad310159c1c1b826feb63a097910bd0a5'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-riscv64'; \
			sha256='eacbc70fd96c4c9a20bd58fc91a756372ece659211b9f566da33e15112c0b2af'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.24.7/docker-compose-linux-s390x'; \
			sha256='23a643f8994c945683f62669cd0f44bc106d3312ea04c3dda39d7514f0b1035e'; \
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
