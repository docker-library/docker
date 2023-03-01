#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.17

RUN apk add --no-cache \
		ca-certificates \
# Workaround for golang not producing a static ctr binary on Go 1.15 and up https://github.com/containerd/containerd/issues/5824
		libc6-compat \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client

# ensure that nsswitch.conf is set up for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/moby/moby/blob/v20.10.21/hack/make.sh#L115
# - https://github.com/golang/go/blob/go1.19.3/src/net/conf.go#L227-L303
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf

ENV DOCKER_VERSION 20.10.23

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-20.10.23.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-20.10.23.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-20.10.23.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.10.3
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.3/buildx-v0.10.3.linux-amd64'; \
			sha256='91f260c9879f8dc8b78912409f8d9f16a3429d457dbcfa0a67169f74837a9290'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.10.3/buildx-v0.10.3.linux-arm-v6'; \
			sha256='1555a3605ae261cad6e64ace62cd3f5e026cee71fca30a3d9d00dd74b90c8662'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.10.3/buildx-v0.10.3.linux-arm-v7'; \
			sha256='07eb9c583f40cb3e3943a228acd05b01245c5b1f45e1ede95b10a1e7ac45b54c'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.3/buildx-v0.10.3.linux-arm64'; \
			sha256='d37e6824d06bcaaf8bbedb2a802d3b0b9a551aa956a22f52dbcfeba65fe8e427'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.10.3/buildx-v0.10.3.linux-ppc64le'; \
			sha256='bc9109501600f12db826ad587d4f342cb9b64e80fdad5b69fac0f75758a912d3'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.3/buildx-v0.10.3.linux-riscv64'; \
			sha256='ef3a7acfb3d991af6a2f846c37b9b02974fd94be1441bb90a7619978467f20cb'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.10.3/buildx-v0.10.3.linux-s390x'; \
			sha256='f743330936b355d2780996f7f0fce296aa4c09fdbdef38775d09c78ca7726e40'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-buildx' architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-buildx' "$url"; \
	echo "$sha256 *"'docker-buildx' | sha256sum -c -; \
	\
	plugin='/usr/libexec/docker/cli-plugins/docker-buildx'; \
	mkdir -p "$(dirname "$plugin")"; \
	mv -vT 'docker-buildx' "$plugin"; \
	chmod +x "$plugin"; \
	\
	docker buildx version

ENV DOCKER_COMPOSE_VERSION 2.16.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-x86_64'; \
			sha256='54ab01967b05e392e6bf13afbc654146890b9fa40501b40aca83a2db18f10427'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-armv6'; \
			sha256='59caa4c31a6515a81b44446d978891c5e1d0f460b9b11e38dea27e1bffdb4cd6'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-armv7'; \
			sha256='558a083683bd597f5e167178dbdbe57824eecf2132bfb497a58f5d39c5e49e8a'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-aarch64'; \
			sha256='edaf196a0b9ebe749aa1a42a6ce4550d2c6c2620762aa98c36088a9b96fd22ef'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-ppc64le'; \
			sha256='aac719dc81ef117bdcca96d7e43ecd605ebcdc1df77c0b09b9d5faf15ccf952e'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-riscv64'; \
			sha256='8c485ee45cf6be4d483179e925ffeb3b046280d1be045cdfc999c0a011ddfcd1'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.16.0/docker-compose-linux-s390x'; \
			sha256='fbaff480bd7901c31ead046652c3f5a3c1236766ce9f52fadfa935a18dd463b8'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-compose' architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-compose' "$url"; \
	echo "$sha256 *"'docker-compose' | sha256sum -c -; \
	\
	plugin='/usr/libexec/docker/cli-plugins/docker-compose'; \
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
