#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.22

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

ENV DOCKER_VERSION 28.3.2

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-28.3.2.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-28.3.2.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-28.3.2.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-28.3.2.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.26.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.0/buildx-v0.26.0.linux-amd64'; \
			sha256='a918c0b8bef7c710a1c6fd74d2d0fce22880226d7662476bd97a82390ce87368'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.26.0/buildx-v0.26.0.linux-arm-v6'; \
			sha256='ce81171133ef280d50ef927e6114f2e30a630ae6dd95dd7ca6b6fde10b136511'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.26.0/buildx-v0.26.0.linux-arm-v7'; \
			sha256='382840ab91992023bbba7f8a7cf770d132856be21219d1c2e23b443535a30443'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.0/buildx-v0.26.0.linux-arm64'; \
			sha256='1685db43ee1131cba9ffab605b68ff418353181454da75b76a8a335fee8553e1'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.26.0/buildx-v0.26.0.linux-ppc64le'; \
			sha256='cbb7ca85b28473a86a9e535c853a68ccafd92f4811cf4bb97873c4ecffb5a7bf'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.26.0/buildx-v0.26.0.linux-riscv64'; \
			sha256='58822a6a4483b08df5df8366f70d8fe57147f35df81c8b722e853129ff1eb0a0'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.26.0/buildx-v0.26.0.linux-s390x'; \
			sha256='e1512f7d0d620d511001bfa2072a6222e47a3433bbd1c9404d9bc0d2b377ea9b'; \
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

ENV DOCKER_COMPOSE_VERSION 2.38.2
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.38.2/docker-compose-linux-x86_64'; \
			sha256='486b3ffc0f806ca2efbc430cef89955386011662f0c76bad17c103d059cfa9cf'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.38.2/docker-compose-linux-armv6'; \
			sha256='3c572ab8554e37e08cd81850464380bfd276b70528d60dcc734d0934380a10c2'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.38.2/docker-compose-linux-armv7'; \
			sha256='ec4786c5c33393d5e366fd6186cbfa116ae30a083666afefc428e4688a222c27'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.38.2/docker-compose-linux-aarch64'; \
			sha256='4d0f7678dd3338452beba4518e36a8e22b20cad79ba2535c687da554dc3997fb'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.38.2/docker-compose-linux-ppc64le'; \
			sha256='4d61ed3f0690c7415bdbe77acf2236121f5a560ff0e41022e2fabecc1690f5a6'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.38.2/docker-compose-linux-riscv64'; \
			sha256='67c65c4015db38b526b262cee9d98915f8fcb56b42be7926a21a7ec2ec0c3d2c'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.38.2/docker-compose-linux-s390x'; \
			sha256='e4aaad3a1a444d7e226ffda3df68795a562f9c3cb0b4805a74c2283036e6e7f0'; \
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
