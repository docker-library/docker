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

ENV DOCKER_VERSION 28.4.0-rc.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-28.4.0-rc.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-28.4.0-rc.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-28.4.0-rc.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-28.4.0-rc.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.27.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.27.0/buildx-v0.27.0.linux-amd64'; \
			sha256='4f5e5a1b6dd0d6ff8476c8def7602d1eeedcb6f602e8dcd45079d352247eba06'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.27.0/buildx-v0.27.0.linux-arm-v6'; \
			sha256='216ef84b075c270ab2f0bbcf9fcedfb0175226349714a129b7806b4b3f1a460c'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.27.0/buildx-v0.27.0.linux-arm-v7'; \
			sha256='b7184384910ed1b3726f7dc340e3c644640fc5f7028c6ccdfda843cfbcb3fb67'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.27.0/buildx-v0.27.0.linux-arm64'; \
			sha256='e3519d085710d2502c673380f763596ae0b378d0ae8976ccbb14adaed82327ef'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.27.0/buildx-v0.27.0.linux-ppc64le'; \
			sha256='e2bc5c418f680fa7ddb8782eea00a56725189ef672019db62b9f526d120afb08'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.27.0/buildx-v0.27.0.linux-riscv64'; \
			sha256='e4f3b40472e3784bf5254eb399aa640205f349ee7c4839db989313d91258b7c6'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.27.0/buildx-v0.27.0.linux-s390x'; \
			sha256='75c24bc03e809ead2e80840280359e3327965c6c1535d0fdc8d48cc86355eecb'; \
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

ENV DOCKER_COMPOSE_VERSION 2.39.2
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-x86_64'; \
			sha256='a55a8cd4ef103aac282812554e531aac8df7e914a287ee81e14d695556a22902'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-armv6'; \
			sha256='a9fefb9f377d11416db7d653fac3c0ed8c61a0ef99c8e17369114b88ac48ab50'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-armv7'; \
			sha256='9d1376146e42bf964f9efa8444935bc20accdc1d72a6ea44881b8d86c9ccfda9'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-aarch64'; \
			sha256='54488fffb60782f3c8787a48b95ed15f49f5a3a85f4105304bd46db5edd9db61'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-ppc64le'; \
			sha256='83a02be63cb047207a6efbd39af13d05b8d38065617764dddc3f6e5d36161d03'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-riscv64'; \
			sha256='911f9a00366a619e15bb56fe37f6a09eddc30dc1d9f704309185fd2eec0fb3f9'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.39.2/docker-compose-linux-s390x'; \
			sha256='af607a5add4d6d0600bece0c6b50ce7fece516e449b17ded33be3445902edce9'; \
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
