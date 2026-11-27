#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.24

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

ENV DOCKER_VERSION 29.10.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.10.1.tgz'; \
			sha256='061642059fa7f2ed9b2f04a327a951cff4249585cf04b2661c2a6539197c9962'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.10.1.tgz'; \
			sha256='0a5d05059d3d82099a35ec7326120f4789f43b1b238ecc318242b178b986f09c'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.10.1.tgz'; \
			sha256='64e904668b30def335d933d5318b6310927a90a68570073d81741af78e71b1fd'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.10.1.tgz'; \
			sha256='a38c8a9ef6d17bce07499bfd3a3688542274769dc3b4f75c06ea2705fe65053e'; \
			;; \
		'ppc64le') \
			url='https://download.docker.com/linux/static/stable/ppc64le/docker-29.10.1.tgz'; \
			sha256='431f36bea426544239e95019e85a1d491b1b4817fd393fc5258fb2f000577791'; \
			;; \
		'riscv64') \
			url='https://download.docker.com/linux/static/stable/riscv64/docker-29.10.1.tgz'; \
			sha256='f30e9d9f642feaf4bc175d8c114f4b0bd4fa0032f2352ffbc1d3269592b9c6bf'; \
			;; \
		's390x') \
			url='https://download.docker.com/linux/static/stable/s390x/docker-29.10.1.tgz'; \
			sha256='c161754580a9e74a8af85a78b9ee7c79a5971676c28113b88f117cafd8036728'; \
			;; \
		*) echo >&2 "error: unsupported 'docker.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'docker.tgz' "$url"; \
	echo "$sha256 *"'docker.tgz' | sha256sum -c -; \
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

ENV DOCKER_BUILDX_VERSION 0.39.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.1/buildx-v0.39.1.linux-amd64'; \
			sha256='903090816da68f8bc1a2ff5346dd163a5adacfce4548d003c75df42cd47a9bf4'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.39.1/buildx-v0.39.1.linux-arm-v6'; \
			sha256='3675402568ec1a5b96792d6bde9ebdafb9d29e9681b7ff747e97d54c2198a735'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.39.1/buildx-v0.39.1.linux-arm-v7'; \
			sha256='e6c51234507ef11ea661a8f714412a5eb9abeba586da73dca82ad89410f03b13'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.1/buildx-v0.39.1.linux-arm64'; \
			sha256='05c88e0f9152825e609a1cdb391faf14d5f94d23d071eaecb87bae69d98da8b8'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.39.1/buildx-v0.39.1.linux-ppc64le'; \
			sha256='69713727c669ca87660c2197a5b97389cbad189120ee405f801986e8459ef83b'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.1/buildx-v0.39.1.linux-riscv64'; \
			sha256='b0af9b8cf5e8e244ea4049b4ca897c77a0b8b0d78c1b1cd7b8324d451de71ed8'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.39.1/buildx-v0.39.1.linux-s390x'; \
			sha256='f611aa33cd5290ad1e2ca6d5357a06123541643698d729392d05a20d527e526e'; \
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

ENV DOCKER_COMPOSE_VERSION 5.8.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.8.1/docker-compose-linux-x86_64'; \
			sha256='cf2713394ca63900da5d00e0be12045634cea93a504e1ab2f2ae24eed7f2d359'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.8.1/docker-compose-linux-armv6'; \
			sha256='bcd23bb30aa1743fd88600b9536dd042395ec148aa19abb6752f91e93894a4a0'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.8.1/docker-compose-linux-armv7'; \
			sha256='33e4ffe998e3aee4bedeac7d1a4546c8937ecf9d87aa377860efd1591c19245f'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.8.1/docker-compose-linux-aarch64'; \
			sha256='e169103deb35aa6633a78eca0a2a0658275d573dd689a33c839c71badfa00cce'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.8.1/docker-compose-linux-ppc64le'; \
			sha256='fc16a478948229883ef48c46347dd34ccf5d27475744c42d39f3e08182dece8c'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.8.1/docker-compose-linux-riscv64'; \
			sha256='6b1021a5d4676ec4bc039926c1bfb4489fa986b74f385cf7d0baf76f71b5d2e2'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.8.1/docker-compose-linux-s390x'; \
			sha256='79ae688c1275925fa8931a58912b7bd7c25953c0b7d0b2382b219f8e40d7b62e'; \
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
