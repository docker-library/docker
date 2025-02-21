#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.21

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

ENV DOCKER_VERSION 28.0.0

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-28.0.0.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-28.0.0.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-28.0.0.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-28.0.0.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.21.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-amd64'; \
			sha256='7f355525bfaf411302570b705118181b720f18071f4be3f0eaac7b2297d826e2'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-arm-v6'; \
			sha256='f841251fd67646e8b6bb4c7e0c2c385f6a1dc7403f5ac6ee7b07c96f0815f7f3'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-arm-v7'; \
			sha256='81d7040e90e9b69cb0378778f673e1fc2a24ef6dbd47931dc83ab6472fc5809d'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-arm64'; \
			sha256='42d5cee287ec7426de5252276a05f3ea565ac2d65d62d052b885a84dd54152d5'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-ppc64le'; \
			sha256='6a4e6a243f83d80cd46c939f327b2e14cfddd2c6690651cf48d0e208c3345b88'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-riscv64'; \
			sha256='eae82aec74a420c3d1734123e6a3bc10b3a2a981aa1d538502373e31c91bf76e'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.21.1/buildx-v0.21.1.linux-s390x'; \
			sha256='97b112b3366a471cc375e0f881d65a9a7b07f0962f308834c37f5c3fa75aad08'; \
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

ENV DOCKER_COMPOSE_VERSION 2.33.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-x86_64'; \
			sha256='3efda1ad6caed49dedd5644cadbf7e0c9cc3d74d8844ca5237b6a43ac1ef1a46'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-armv6'; \
			sha256='17e66154ed90d43d4c26dec4a77caeaa6f0a8337f436cc4bffecbc2fd9bcd27d'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-armv7'; \
			sha256='0104e689d29597352a715f7027205d7517f17f449ffe14099aa9d5d0a54f7073'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-aarch64'; \
			sha256='fa0e077510c852237b0da426d0daf6853446e7760145ce7665ec401892a4d0de'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-ppc64le'; \
			sha256='79d874b04c972475867e2e1f69febdadc446289af32afaa0dcb99f48a25380cc'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-riscv64'; \
			sha256='8a51f33cb82afc6b7ce1c02b3161ce928387e96efa7b838e2f9f1fa554d68781'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.33.1/docker-compose-linux-s390x'; \
			sha256='bae7fd067dd05951e4c6cb66199d2e7f388b5c19856db760fe4253dfdf2a008e'; \
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
