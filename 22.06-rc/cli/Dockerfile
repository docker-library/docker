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

ENV DOCKER_BUILDX_VERSION 0.9.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-amd64'; \
			sha256='a7fb95177792ca8ffc7243fad7bf2f33738b8b999a184b6201f002a63c43d136'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-arm-v6'; \
			sha256='159925b4e679eb66e7f0312c7d57a97e68a418c1fa602a00dd8b29b6406768f0'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-arm-v7'; \
			sha256='ba8e5359ce9ba24fec6da07f73591c1b20ac0797a2248b0ef8088f57ae3340fc'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-arm64'; \
			sha256='bbf6a76bf9aef9c5759ff225b97ce23a24fc11e4fa3cdcae36e5dcf1de2cffc5'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-ppc64le'; \
			sha256='1b2441886e556c720c1bf12f18f240113cc45f9eb404c0f162166ca1c96c1b60'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-riscv64'; \
			sha256='c32372dad653fc70eb756b2cffd026e74425e807c01accaeed4559da881ff57c'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.9.1/buildx-v0.9.1.linux-s390x'; \
			sha256='90b0ecf315d741888920dddeac9fe2e141123c4fe79465b7b10fe23521c9c366'; \
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

ENV DOCKER_COMPOSE_VERSION 2.11.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-x86_64'; \
			sha256='e15e0d04bb2ae3885a375a575f27ebd79679f01df2dcb1257bd2c5afe1966122'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-armv6'; \
			sha256='25b8aca3e61654be4324080ccb758f47a165c6028b57d2c4b4a0bae967274a4e'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-armv7'; \
			sha256='d13b829fc9637bbf291cd4c90ddc19da7d9c69e4788399641e01657f93208c9e'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-aarch64'; \
			sha256='26088a6f1afbb58c78b2d7a7eaa0ec36df59f9f45729843ca1031ec75472b6bc'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-ppc64le'; \
			sha256='44334a3632c9a34a519860c1edc2f251addbcace694ec38f04a5d825358d9fd9'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-riscv64'; \
			sha256='dd6cf7a96fec0abd69be360f525e21ae85b97b18e45dd393feee1678457fc1b9'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.11.0/docker-compose-linux-s390x'; \
			sha256='fc350527128f6ed0fb71baed1df0f905217c1ac90565be5b57c2a3d784de0e14'; \
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
