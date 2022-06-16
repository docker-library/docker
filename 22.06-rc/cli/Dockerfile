#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.16

RUN apk add --no-cache \
		ca-certificates \
# Workaround for golang not producing a static ctr binary on Go 1.15 and up https://github.com/containerd/containerd/issues/5824
		libc6-compat \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client

# set up nsswitch.conf for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/docker/docker-ce/blob/v17.09.0-ce/components/engine/hack/make.sh#L149
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV DOCKER_VERSION 22.06.0-beta.0
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-22.06.0-beta.0.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-22.06.0-beta.0.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-22.06.0-beta.0.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-22.06.0-beta.0.tgz'; \
			;; \
		*) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O docker.tgz "$url"; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	docker --version

ENV DOCKER_BUILDX_VERSION 0.8.2
RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-amd64'; \
			sha256='c64de4f3c30f7a73ff9db637660c7aa0f00234368105b0a09fa8e24eebe910c3'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-arm-v6'; \
			sha256='d0e5d19cd67ea7a351e3bfe1de96f3d583a5b80f1bbadd61f7adcd61b147e5f5'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-arm-v7'; \
			sha256='b5bb1e28e9413a75b2600955c486870aafd234f69953601eecc3664bd3af7463'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-arm64'; \
			sha256='304d3d9822c75f98ad9cf57f0c234bcf326bbb96d791d551728cadd72a7a377f'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-ppc64le'; \
			sha256='32b317d86c700d920468f162f93ae2282777da556ee49b4329f6c72ee2b11b85'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-riscv64'; \
			sha256='76d5fcf92ffa31b3e470d8ec1ab11f7b6997729e5c94d543fec765ad79ad0630'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.8.2/buildx-v0.8.2.linux-s390x'; \
			sha256='ec4bb6f271f38dca5a377a70be24ee2108a85f6e6ba511ad3b805c4f1602a0d2'; \
			;; \
		*) echo >&2 "warning: unsupported buildx architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	plugin='/usr/libexec/docker/cli-plugins/docker-buildx'; \
	mkdir -p "$(dirname "$plugin")"; \
	wget -O "$plugin" "$url"; \
	echo "$sha256 *$plugin" | sha256sum -c -; \
	chmod +x "$plugin"; \
	docker buildx version

ENV DOCKER_COMPOSE_VERSION 2.7.0
RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-x86_64'; \
			sha256='184df811a70366fa339e99df38fc6ff24fc9e51b3388335efe51c1941377d4ce'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-armv6'; \
			sha256='a5fc14755a5de6c0998907a73b1eb115e3e45b80a05d284fecab2825a3722fca'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-armv7'; \
			sha256='53ed781ff04efa2e93fc6e0c02fc3c7d792083780c747ef06e9e0e46e8bb7eb1'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-aarch64'; \
			sha256='bcc79aff65b35581246feca30d53261eddcfc79285868061b31f3ff86d102563'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-ppc64le'; \
			sha256='a9de33aa3a306ee5a36d2d94e1dd88a5dea1330e774e27d1d7458d44c94d36f9'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.7.0/docker-compose-linux-s390x'; \
			sha256='429498246e1d4778669e781a70e659ba59fa8bb3cdee45f8ce8e01a716a12aff'; \
			;; \
		*) echo >&2 "warning: unsupported compose architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	plugin='/usr/libexec/docker/cli-plugins/docker-compose'; \
	mkdir -p "$(dirname "$plugin")"; \
	wget -O "$plugin" "$url"; \
	echo "$sha256 *$plugin" | sha256sum -c -; \
	chmod +x "$plugin"; \
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
