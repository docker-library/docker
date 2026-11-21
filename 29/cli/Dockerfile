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
			url='https://download.docker.com/linux/static/stable/x86_64/docker-cli_29.10.1.tgz'; \
			sha256='27f08878ebbe062e4cf32f2b7c14f7a40b0fb93b92570fcd750c75de77a2fcaa'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-cli_29.10.1.tgz'; \
			sha256='14fa0513f407ac7ea3a1eb7d6a9ad88f07f8a64e26665490ad75913bae9fcee3'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-cli_29.10.1.tgz'; \
			sha256='0c2e7e9e264f740d59895617bd539bd6e17b29a9e94e847921571cc609e13fab'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-cli_29.10.1.tgz'; \
			sha256='866fd254309313bf714eb8116f8ea058ada51401d2d183e7670b00bef2f2d941'; \
			;; \
		'ppc64le') \
			url='https://download.docker.com/linux/static/stable/ppc64le/docker-cli_29.10.1.tgz'; \
			sha256='c7b3761fb9b799e034071547f8ef976f0b70690c10a51835f1b9d4a696a499d5'; \
			;; \
		'riscv64') \
			url='https://download.docker.com/linux/static/stable/riscv64/docker-cli_29.10.1.tgz'; \
			sha256='19c956d1330598ef980c4e9d4065890e61d3c7154b801679792be8a37171f3ef'; \
			;; \
		's390x') \
			url='https://download.docker.com/linux/static/stable/s390x/docker-cli_29.10.1.tgz'; \
			sha256='34f35ed000bf32125ff6ed6e62e2fe48f3f459da35fdd65f8a4e48a144521574'; \
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
		'bin/docker' \
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

ENV DOCKER_COMPOSE_VERSION 5.8.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-linux-x86_64'; \
			sha256='b8840f5008c447f41fce0a57ae3adeab42c89b1eb6e6012524bcabbfb4ffbaf6'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-linux-armv6'; \
			sha256='c88658466ae9a4dadae64e6a4ec125202212bd460934537bd482bcd5e313f57b'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-linux-armv7'; \
			sha256='a7a79755648b975b66df08b4bfbe12b29f113d5dd8c7cd5b6b53b69efff2f422'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-linux-aarch64'; \
			sha256='1a9c918b2fb49b9c87f0018c64b5abd0d30715155e98dc939779fbaee6c414d3'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-linux-ppc64le'; \
			sha256='921437ba1fe9b5f7e3146c74c4d6c56673881741561c71bc23106b1e45886b1d'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-linux-riscv64'; \
			sha256='0af052a262dcf3a28214c7c86442046fc5e50b698e838d1904395d7a5333b142'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.8.0/docker-compose-linux-s390x'; \
			sha256='444af1a82eb51edd4a2aa5b1a209724f2acd19644e488fbd8c1dc8fd7d477f97'; \
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
