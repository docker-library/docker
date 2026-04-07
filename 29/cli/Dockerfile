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

ENV DOCKER_VERSION 29.4.0

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.4.0.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.4.0.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.4.0.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.4.0.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.33.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.33.0/buildx-v0.33.0.linux-amd64'; \
			sha256='9426a15411f35f635afef3f5d3bae53155c3e30d26dee430cc968e13d34be49f'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.33.0/buildx-v0.33.0.linux-arm-v6'; \
			sha256='b33311b149623316b840ce25f0b6686433c6aecaca560d8b35906423f8f597bb'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.33.0/buildx-v0.33.0.linux-arm-v7'; \
			sha256='4d80358ce3d217f38ac9e914cb8501fd4a8a45bc3ac3c23d303e623f275a45df'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.33.0/buildx-v0.33.0.linux-arm64'; \
			sha256='204dc28447d3bb48f42ed1ce5747e0885cd57e306506a39029311becdb1ef786'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.33.0/buildx-v0.33.0.linux-ppc64le'; \
			sha256='46b0444858c8db8c6f741dca20b815f50046a2d73f4874a54dae2719df145ad3'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.33.0/buildx-v0.33.0.linux-riscv64'; \
			sha256='5003b19409f2dfb38fc5f00a8eac4b1d810f6087b88ae007c6983287b93095dd'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.33.0/buildx-v0.33.0.linux-s390x'; \
			sha256='17fbec8163440e73d1e784d55faf483b17782aac471d867a525fa370f3ed317c'; \
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

ENV DOCKER_COMPOSE_VERSION 5.1.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.1.1/docker-compose-linux-x86_64'; \
			sha256='2ac954c9d506b912a12477d72f01601dc72ec918c429c7bae48fd707bdf0f3e5'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.1.1/docker-compose-linux-armv6'; \
			sha256='dbc7d5be282b2f465fb76841588e446f5fee10104c73428e8130bfa9baf1f1e2'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.1.1/docker-compose-linux-armv7'; \
			sha256='5cf43b83c705b24df9dbee1d35a6f085189ee2c1169444147192daf932683ed4'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.1.1/docker-compose-linux-aarch64'; \
			sha256='4b5c42952b7dd81f508d01a771df2a9e5dbffe9b8c5c7d983e738504ad38f056'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.1.1/docker-compose-linux-ppc64le'; \
			sha256='e131760ddd58dd5fc42b80ce9e4c49ecb6e8c26638a1c4bc3aa526f58c2440bf'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.1.1/docker-compose-linux-riscv64'; \
			sha256='8f0df39eaf9014bce4c2505c91d067eb22631e894caabba7c5dae56c72c316f2'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.1.1/docker-compose-linux-s390x'; \
			sha256='87c0b606dcaf49b61f651f2b4e946e03a14e06e1dc16557a408a85e9796884f2'; \
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
