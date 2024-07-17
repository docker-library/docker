#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.20

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

ENV DOCKER_VERSION 24.0.9

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-24.0.9.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-24.0.9.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-24.0.9.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-24.0.9.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.16.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-amd64'; \
			sha256='9a9a6ca0b929a57db01020fb226b1a2ea2bc57eba63d4adec46c43d0009506e2'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-arm-v6'; \
			sha256='902f1240a6071c721f9746f0ff0859ef7b7368b683e322c08a1daa92d61d698a'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-arm-v7'; \
			sha256='81d53f05d1d02306844f5a364cae6d7ad24451497c171ee29e1c000a78f30c5c'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-arm64'; \
			sha256='1aa8f0438866c706654a6dd96e211e509d42b16b1a0e66c1777c95edb2f14f49'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-ppc64le'; \
			sha256='569f4a47bca797385eccac18e14e1d4bb681e35eeff6304c432de5bcd543120d'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-riscv64'; \
			sha256='e0cfc5072a792088115560e77a8540c9bf8299716984d42adc0735161472f076'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.16.0/buildx-v0.16.0.linux-s390x'; \
			sha256='80ff8dcddbc3d0306e5cb819eddf89ce970ea1dbf806eb0adf7b6cd616d1da63'; \
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

ENV DOCKER_COMPOSE_VERSION 2.29.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-x86_64'; \
			sha256='fb3f6c317056ec54e8756851663ca788521f7a9c60afb8a595bc7a05ffaa8951'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-armv6'; \
			sha256='e1f2942bff7e16556675e46db6e30d6ecbed2e78656c760b8e25383817b7a328'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-armv7'; \
			sha256='7ca096778a30c349816f67ce772709164eddaf3022901bf55472ae3134264cf6'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-aarch64'; \
			sha256='49941418051846d72c74dd8df1f8b4ff753ca74d29986361d937384fbfb63569'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-ppc64le'; \
			sha256='45606de42e140e20eadb7f8a9db62f783de7df6c148640cd67cf8f9ef3aaab99'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-riscv64'; \
			sha256='e685bb6ad60225dc099acf85cfbb928e5ceef26a1a61f4995d1fbabac438d0e2'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.29.0/docker-compose-linux-s390x'; \
			sha256='94622d0476d9f59b40c24daa22231c603a93fd9acc984c4427ca946dfb4a908c'; \
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
