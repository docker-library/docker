#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.16

RUN apk add --no-cache \
		ca-certificates \
# Workaround for golang not producing a static ctr binary on Go 1.15 and up https://github.com/containerd/containerd/issues/5824
		libc6-compat \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client

# set up nsswitch.conf for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/docker/docker-ce/blob/v17.09.0-ce/components/engine/hack/make.sh#L149
# - https://github.com/golang/go/blob/go1.9.1/src/net/conf.go#L194-L275
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ ! -e /etc/nsswitch.conf ] && echo 'hosts: files dns' > /etc/nsswitch.conf

ENV DOCKER_VERSION 22.06.0-beta.0

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-22.06.0-beta.0.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-22.06.0-beta.0.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-22.06.0-beta.0.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-22.06.0-beta.0.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.9.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.9.0/buildx-v0.9.0.linux-amd64'; \
			sha256='513e2cb7e71a21e20ae7709eb2fcc98d66117bd440d98602a84835e5cd3179bf'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.9.0/buildx-v0.9.0.linux-arm-v6'; \
			sha256='fe7390cc5a72420a5661cd580eedf08808d9271a305bdc32e00841fb2f44c5d9'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.9.0/buildx-v0.9.0.linux-arm-v7'; \
			sha256='35d7ee9bb8ddee9715c27ad5fa1512d56dd3b3c6a13137699643d07a932eb08b'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.9.0/buildx-v0.9.0.linux-arm64'; \
			sha256='c288ee151a30eb6afe68937600c96eb4b6e1932c9ef46584304438b85756cea6'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.9.0/buildx-v0.9.0.linux-ppc64le'; \
			sha256='4a324d4ae294526c9e5f3c6544a9c95009537eb38530e3fbb0940dd3f9b8d6d6'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.9.0/buildx-v0.9.0.linux-riscv64'; \
			sha256='794fdce2c09178dae2c7dafae75aa5c0d888e95164f419820b05e0674675b65d'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.9.0/buildx-v0.9.0.linux-s390x'; \
			sha256='81d7d84d05a6e24677d22cd812a5ba1cbfb15e44ccba652f4dfa5e3076bb58ce'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-buildx' architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-buildx' "$url"; \
	echo "$sha256 *"'docker-buildx' | sha256sum -c -; \
	\
	plugin='/usr/libexec/docker/cli-plugins/docker-buildx'; \
	mkdir -p "$(dirname "$plugin")"; \
	mv -vT 'docker-buildx' "$plugin"; \
	chmod +x "$plugin"; \
	\
	docker buildx version

ENV DOCKER_COMPOSE_VERSION 2.9.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-linux-x86_64'; \
			sha256='3be9ce88ecba41b734e3fc8e59a9b11531133761414a78827d1615aadb5ef1f5'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-linux-armv6'; \
			sha256='2ea0f36350f81ae66db2b8c12104de6ed974a328557a4967857ee6e8df4b8f26'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-linux-armv7'; \
			sha256='658db542e40c8063cdafc23f650493bedc10b41b6d6fb581b7866bfeb5ffb0ba'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-linux-aarch64'; \
			sha256='6d227b060b2bc3dc5f315a07ae4f647f042755691e2da905b1a21e60a8ae3ddf'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-linux-ppc64le'; \
			sha256='101ea490283f3c862e9bb4e7ef2a3fb38393cf2139f2b78e7a7423c91ad0c1fa'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.9.0/docker-compose-linux-s390x'; \
			sha256='0826c101e1d1a070e8ab8d7649c0da3cb9e6ecf1e717c545188243be6e676d00'; \
			;; \
		*) echo >&2 "warning: unsupported 'docker-compose' architecture ($apkArch); skipping"; exit 0 ;; \
	esac; \
	\
	wget -O 'docker-compose' "$url"; \
	echo "$sha256 *"'docker-compose' | sha256sum -c -; \
	\
	plugin='/usr/libexec/docker/cli-plugins/docker-compose'; \
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
