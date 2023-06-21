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
# - https://github.com/moby/moby/blob/v20.10.21/hack/make.sh#L115
# - https://github.com/golang/go/blob/go1.19.3/src/net/conf.go#L227-L303
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf

ENV DOCKER_VERSION 23.0.6

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-23.0.6.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-23.0.6.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-23.0.6.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-23.0.6.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.11.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-amd64'; \
			sha256='ec2c9da22c3b733ad96d6a6897750153d884f1b2b86f2864ee5f743ce931055d'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-arm-v6'; \
			sha256='a925462288a55b709a42431fe39bb0e67f033961f02a4754897c4a388355feea'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-arm-v7'; \
			sha256='e3f18a0d10346d8e53aff743fccfc0b95e45dc0235c3b0b72b49d3452c72b9e0'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-arm64'; \
			sha256='e50f34f8feb7004407f826a375090bec6191891c473347b41b05cf5864bc5240'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-ppc64le'; \
			sha256='de8670ab6b2c34feb32289d04af07014bb4517de879d1fdb6e31a00da28f1df4'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-riscv64'; \
			sha256='a07ad5791d6e60094e38147ef5f5eac406b2692aa380eae5ac866bde91bcdc89'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.11.0/buildx-v0.11.0.linux-s390x'; \
			sha256='fc1a57b9fb69f7736908bbea94013eb17b5ae03cd5ed99b0bd61e223f9b6e4a7'; \
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

ENV DOCKER_COMPOSE_VERSION 2.19.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-x86_64'; \
			sha256='34e3b754d13eab683222f67827e20f640dfe0630b3b786c49a9de3f7fc7400a6'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-armv6'; \
			sha256='49ba58cabcdc0778507f152baa2a84ef5d1417ac3dc4d7f4fbd492a77ec0638b'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-armv7'; \
			sha256='0c0e3af9ae2b833e09b303899ef3330d40c09ec13a4def861c22b3d0a7ec8540'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-aarch64'; \
			sha256='c963c6d913a57e0571104ecb8f8ba0502516eafd7b784b5abc4a0d96ebb54d04'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-ppc64le'; \
			sha256='317696f8a7cefc244d2e97779b926da93ce3bfb95be5ca56dde868c495560d50'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-riscv64'; \
			sha256='e1b150cb49b34598c7b06985df5f19268394869902e787aa6a0542e700c20a50'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-linux-s390x'; \
			sha256='83cb57f3b8025afd7002f0ab48056e857ce2d8aece9ff47193c772d05966a137'; \
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
