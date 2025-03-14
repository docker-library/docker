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

ENV DOCKER_VERSION 28.0.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-28.0.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-28.0.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-28.0.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-28.0.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.21.2
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-amd64'; \
			sha256='b13bee81c3db12a4be7d0b9d042b64d0dd9ed116f7674dfac0ffdf2a71acfe3d'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-arm-v6'; \
			sha256='70dabedf4afe192e23a00c0bfe6ecda000545059abfce339f72f45b41f4fbb45'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-arm-v7'; \
			sha256='c41700549bbf783e861cfe0c918aa152ece87cac099a260995b3822e75e3838b'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-arm64'; \
			sha256='7e21e62eae3243e476411c9bbe93b8ee59b5d62ddf075c527d168174c3ab3a04'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-ppc64le'; \
			sha256='c817caec1e697484e8375d0fda499407e9081c8952db62edf702ccbb5d93187c'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-riscv64'; \
			sha256='cdac31a493fc19fab46962bbbb4fdec6d14c1549c1b5cacafc7eb5d60fe11b75'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.21.2/buildx-v0.21.2.linux-s390x'; \
			sha256='bd89f667a10870a9ce11e60a1028a2fa0395c85f27ba0faaf8d338771fb65416'; \
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

ENV DOCKER_COMPOSE_VERSION 2.34.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-x86_64'; \
			sha256='94a416c6f2836a0a1ba5eb3feb00f2e700a9d98311f062c4c61494ccbf3cd457'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-armv6'; \
			sha256='f581de955d332f10323ff98dc3faf4b13f7ba9c5372dac3b389ad28f8dc85b1e'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-armv7'; \
			sha256='9080c489047880546b0269b74d0750d94ef604fe4a3c11b2e5dfad436b1e4fa6'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-aarch64'; \
			sha256='cd1ef5eda1119edb9314c0224bac97cee14a9c31909a0f7aa0ddfe266e08adaa'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-ppc64le'; \
			sha256='ec2c9e4083ce1bd6b3c30ddd30002bc5d9c83b4749a20e853ea73e1e14ad7b9c'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-riscv64'; \
			sha256='5d3bf73eb9fa9f7576ba8f2bc2f231b684b453b747dc55b6cadde7566c34f6dc'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-s390x'; \
			sha256='558955aebe0f5965bd5e9449415a746905a7f4c58f8642946e576becf1745376'; \
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
