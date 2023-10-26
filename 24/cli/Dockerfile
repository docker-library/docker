#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.18

RUN apk add --no-cache \
		ca-certificates \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client

# ensure that nsswitch.conf is set up for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/moby/moby/blob/v24.0.6/hack/make.sh#L111
# - https://github.com/golang/go/blob/go1.19.13/src/net/conf.go#L227-L303
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf

ENV DOCKER_VERSION 24.0.7

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-24.0.7.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-24.0.7.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-24.0.7.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.11.2
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-amd64'; \
			sha256='311568ee69715abc46163fd688e56c77ab0144ff32e116d0f293bfc3470e75b7'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-arm-v6'; \
			sha256='c1bab0c7374406d5069f60b291971d71161fbd3c00e8a8fb1b68b9053eda8a4e'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-arm-v7'; \
			sha256='4defdf463ca2516d3f58fef69a6f78cbbb8baf16d936cdfc54df4a4be0d48f7f'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-arm64'; \
			sha256='565e36085a35bba5104f37365ba796c111338eea1a0902b3a7ff42e2e1248815'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-ppc64le'; \
			sha256='c5f5cb9957890873a537c7ff5c4eef36132339622baeabb37a4b9b7251ddf836'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-riscv64'; \
			sha256='c0adc4b4625f7e3df7dcdec840568f918673f2ed4bcd03ca1e63ea2a5627ca35'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.11.2/buildx-v0.11.2.linux-s390x'; \
			sha256='02916c76c3872fd0b3fa57e71403fee92b6be10f350b96a5ff99e7914dd277b8'; \
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

ENV DOCKER_COMPOSE_VERSION 2.23.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-x86_64'; \
			sha256='6e06123399e5428fbd603564afdac74821fa0a7b4465e8a1a2359b362fc42fc4'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-armv6'; \
			sha256='75889ad81c5b0b07805920e398eaa7fb41c1321c81942daa07a5b5c5a1a27bdb'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-armv7'; \
			sha256='2cd4af627462720384cfd2ba24d951854707d7c1fa37618c9e0319139f8a2012'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-aarch64'; \
			sha256='5c09e2c6b1cd9fc1be535690ee62712687ad12f0d08b14c27d30442f0e85b955'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-ppc64le'; \
			sha256='ff524f6d11050483abda01c5b1b33626c6c2f1b835df8514db6a42148d5095fc'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-riscv64'; \
			sha256='00302be14ad7d981eb86b834c09deb8186231b416c16454f9971bfcc0ec7e22f'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-linux-s390x'; \
			sha256='323c2e92b3150ef94dc4201770e06ed7bacbe811abd77a23108cceea032fcf63'; \
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
