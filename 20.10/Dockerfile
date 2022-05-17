#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.15

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

ENV DOCKER_VERSION 20.10.16
# TODO ENV DOCKER_SHA256
# https://github.com/docker/docker-ce/blob/5b073ee2cf564edee5adca05eee574142f7627bb/components/packaging/static/hash_files !!
# (no SHA file artifacts on download.docker.com yet as of 2017-06-07 though)

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-20.10.16.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-20.10.16.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-20.10.16.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-20.10.16.tgz'; \
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

ENV DOCKER_COMPOSE_VERSION 2.5.1
RUN set -eux; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-x86_64'; \
			sha256='d99de1ea7616f2a4c7914d37674f0650660a5e832be555805a71c0fc377233c9'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-armv6'; \
			sha256='86f2eafdb2ff1f3885758854dd5e1c5ea9d81aa292623829fd3babe9d3fc6f9a'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-armv7'; \
			sha256='f5a15fa6ef16f3c79cf8c2e965d7426d1f3968c273eb588c76d1f2851b1bf90f'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-aarch64'; \
			sha256='002662ed18a22d9d65d3d2c0358008c7c6a3db7dacb8983488130b3954d00e63'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-ppc64le'; \
			sha256='83612098d39d3485945ee0d49f1ede02e0de96fbb7658202770aec6ae0834853'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.5.1/docker-compose-linux-s390x'; \
			sha256='68b9487106fd27e0f8c7defcf80fee2ab4f178f3ccc1d827fa0d2e82f80fa38b'; \
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
