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

ENV DOCKER_VERSION 28.3.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-28.3.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-28.3.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-28.3.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-28.3.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.25.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.linux-amd64'; \
			sha256='4104d79a791a8744c0b43fd5bd0a6172dff29040c5229946a1cdb2d27b0b5bfa'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.linux-arm-v6'; \
			sha256='4b92125aa797875108174d9d8ae2e92bdf1db82c97dcf8b3bb72490a62fd8122'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.linux-arm-v7'; \
			sha256='0c943fa7001cde147ab7663e36c92259ddde2a3ce0b6f5dfcbc3535dc67f8661'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.linux-arm64'; \
			sha256='f07063844bb750172c1f25cef61b07a8314d24bedffc015517b3ec4016b16de8'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.linux-ppc64le'; \
			sha256='9ac89d1401b105be41e98760aaaae00e4f44e180e757bf6044d2824ff14788bf'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.linux-riscv64'; \
			sha256='17829ab06c8ec984201170bfb676e6cd311312983814354505fb679b36c02177'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.25.0/buildx-v0.25.0.linux-s390x'; \
			sha256='1b4a7d86fee5b6a48fd153418bd6ed8f0c82bc5d7eb3b219052e834ece977440'; \
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

ENV DOCKER_COMPOSE_VERSION 2.38.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.38.1/docker-compose-linux-x86_64'; \
			sha256='d94a60549c6916499ce41959941e6c88b67c23ed98d1c5eee2cfc4a2d58aa24b'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.38.1/docker-compose-linux-armv6'; \
			sha256='1025f08f0a91bac695376a118dc95c50bc8a7bb77558bd486a12eeff1aac63b9'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.38.1/docker-compose-linux-armv7'; \
			sha256='f9d95a3bf756be4c6be661ab5799e9cb62423d24fd4bf65d9c59fa6ffbc1a525'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.38.1/docker-compose-linux-aarch64'; \
			sha256='f7e9ed22cf330018cdc3e802e59cacb7fff3520d62aa111ac6640e00597a0ebc'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.38.1/docker-compose-linux-ppc64le'; \
			sha256='d4994e1b0d5d00c6f09f9f88a7ad135a96d8e48f8fc4238896a152def0a0c65b'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.38.1/docker-compose-linux-riscv64'; \
			sha256='316569c1e2fb518ea141a1995b4de475ae12332a7e72bfb5a2fe25fa2feaa46b'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.38.1/docker-compose-linux-s390x'; \
			sha256='421afc85b17ad6ae4667f209db337d18a8c74f567f99fac6bca0aa0f787697db'; \
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
