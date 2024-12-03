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

ENV DOCKER_VERSION 27.3.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-27.3.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-27.3.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-27.3.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-27.3.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.19.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.19.1/buildx-v0.19.1.linux-amd64'; \
			sha256='153eace3d30c9efe9a7b94ea06c9d15ace59c8e6268d3481b8c175bd3df020f9'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.19.1/buildx-v0.19.1.linux-arm-v6'; \
			sha256='6f7e15248535bcae3730444bbf6164d076b9df7491b89040153f12d9e93a9f6b'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.19.1/buildx-v0.19.1.linux-arm-v7'; \
			sha256='b2bb531e4f217c94951173a9e403002f6b18868227f09715c295a63f837cf5e4'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.19.1/buildx-v0.19.1.linux-arm64'; \
			sha256='9ecffda0a356957827de6b4ed86b151b420e84f81b2a58e2e2735506336ab891'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.19.1/buildx-v0.19.1.linux-ppc64le'; \
			sha256='10ab6f3effac50e4150a3288013ad34e3cf4a0b307c7ffbf48dda9a5813e1bda'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.19.1/buildx-v0.19.1.linux-riscv64'; \
			sha256='c89af9a424a109abd52205544377a9eac6027bb91c2fbe91d02cf91a6b53f7e8'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.19.1/buildx-v0.19.1.linux-s390x'; \
			sha256='cfaf3883fe66787297c8df69e25f95246a74d630b5e2b6627cc563246f94b4f9'; \
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

ENV DOCKER_COMPOSE_VERSION 2.31.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-x86_64'; \
			sha256='8b5d2cb358427e654ada217cfdfedc00c4273f7a8ee07f27003a18d15461b6cd'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-armv6'; \
			sha256='5812e2fe5e8fdbaa984679ad5809779a0a0f054a423a63f6d15167b5d643db43'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-armv7'; \
			sha256='f8271667b0b0337cdd11a0f2920089f09b06bb4e5e3988e66ab23b5d18c3fa18'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-aarch64'; \
			sha256='a1f85584584d0c3c489f31f015c97eb543f1f0949fdc5ce3ded88c05a5188729'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-ppc64le'; \
			sha256='0f6149bb38f1722dea511fc80228d9bc7c3504cedaf662e09033d3aa89c70d93'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-riscv64'; \
			sha256='f3f9a94dc4bb8773bdcd70680a177171e8aeb15b98b979fe51b447a5c97c52d1'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.31.0/docker-compose-linux-s390x'; \
			sha256='6635a146193c797ed11ba3a6e9d7b1da5df0f1215ccd3c52f712001e58413f20'; \
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
