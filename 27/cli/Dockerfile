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

ENV DOCKER_VERSION 27.3.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-27.3.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-27.3.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-27.3.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.17.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-amd64'; \
			sha256='aa7a9778349e1a8ace685e4c51a1d33e7a9b0aa6925d1c625b09cb3800eba696'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-arm-v6'; \
			sha256='8c287b02430036d42323052e228ee8e26a6e7f7c5858b170f6f82be812d8043b'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-arm-v7'; \
			sha256='5454c2feddb76000c22cb8abafe8f4a03e6fee12aae9031f9e02b661e76012c8'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-arm64'; \
			sha256='de05dccd47932eb9fd6e63781ab29d2b0b2c834bbdd19b51d7ea452b1fe378d3'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-ppc64le'; \
			sha256='29b4f2de5a1e6ecb4096868111d693a8ba4aaf144d535242ce19fc4154f94a4e'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-riscv64'; \
			sha256='e67d26acb10c4529b9b5ca4e20781865d63e538228c566af6d1e91da65cdb992'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.17.1/buildx-v0.17.1.linux-s390x'; \
			sha256='9a3a4376025d1c2771ac69aceff0bcb19a2594413e318a34455af037ce903f06'; \
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

ENV DOCKER_COMPOSE_VERSION 2.30.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.30.1/docker-compose-linux-x86_64'; \
			sha256='bd976a501e471c14b320876686f1628db3c37ab223405d2a815022fc711e704e'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.30.1/docker-compose-linux-armv6'; \
			sha256='2c70bd6e01ceb550d81a1bb0981f8f24c58ec301ac0c1432db132e07842544fe'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.30.1/docker-compose-linux-armv7'; \
			sha256='205f947e00fdfb2d4787fb5d38267d56e68bbf07757d8e30d7b1c9c1086c8477'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.30.1/docker-compose-linux-aarch64'; \
			sha256='f869d0900f8744b3f295c5bf8ed68488110598891d3db1d93db7203db9fa535b'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.30.1/docker-compose-linux-ppc64le'; \
			sha256='93e47b53fcaaa366555cfa92ff49c77c16e2d76ccf26f816db24683b6bdb36ac'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.30.1/docker-compose-linux-riscv64'; \
			sha256='0431d523628c26e74308be72205d13866bc978970b2e98efc60f5ecf23089ed2'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.30.1/docker-compose-linux-s390x'; \
			sha256='afed38f2f18219d3fe79f2f0bc11d21458195c7f19d812c3ecd1a2608094fa84'; \
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
