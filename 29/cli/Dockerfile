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

ENV DOCKER_VERSION 29.10.0

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.10.0.tgz'; \
			sha256='7c1ebadc65c716cdc6d35fc78759ed0e4317debf43c21dd12f066f2006999def'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.10.0.tgz'; \
			sha256='b3e626f7560728eb601687da86c27edf9b7dd71f6a0f00737baeeb607c0f1d68'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.10.0.tgz'; \
			sha256='08757af1f923c25d170211a1de8acc4e69e9cfbe7b5af63dd787afe2057efd5f'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.10.0.tgz'; \
			sha256='6e5159e8b5615e0c0c2954a2a1a2a12bc65f5d9b603595dba24a10cb367408cd'; \
			;; \
		'ppc64le') \
			url='https://download.docker.com/linux/static/stable/ppc64le/docker-29.10.0.tgz'; \
			sha256='f07fe44072d1614de38effa6492f840653dfbf9e5a7d3a0a1dab4c2dad257190'; \
			;; \
		's390x') \
			url='https://download.docker.com/linux/static/stable/s390x/docker-29.10.0.tgz'; \
			sha256='09c4a2ec475121fe9c1485c65e9f54f1fa20aa4d68d0c4b271005db3943a763b'; \
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

ENV DOCKER_BUILDX_VERSION 0.39.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-amd64'; \
			sha256='5fb31a097304fbf6dd4038649a0decf32c2b9510e4047acd7d68b9d700c46194'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-arm-v6'; \
			sha256='462b5699af263c05c5c1d973ab33f41810c263585d5b8b3dcfa6f7d3a11bc987'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-arm-v7'; \
			sha256='a49d315f68f6ed91b2ea88da4259b418abe015be68460e0eebe0b8d9f74970b1'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-arm64'; \
			sha256='722cdcdfdd6f3fb943fa1ba75102d057feb18ba72aab93b1b0a8cf2b2b48a25f'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-ppc64le'; \
			sha256='dd7b1f65b7432229a619d3b92ddbdd742fb26fa8b4a281a99489431ef5e041b7'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-riscv64'; \
			sha256='58d328fe5a8e58f4e5934913c1f7c51d6633f197d28f3114fe2cb9026cfb5d74'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.39.0/buildx-v0.39.0.linux-s390x'; \
			sha256='754f15a88f4496b5ddea3ac5626dd068f836965f799253a6402b07d324c45892'; \
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
