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

ENV DOCKER_VERSION 29.0.2

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.0.2.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.0.2.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.0.2.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.0.2.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.30.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.30.0/buildx-v0.30.0.linux-amd64'; \
			sha256='460680948a25b80e62ffe085cd2d7ef4088540f3f3f58734b445a31534198240'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.30.0/buildx-v0.30.0.linux-arm-v6'; \
			sha256='bb50ae022407e185f9e77b5e8fec7b4460c3dab5b2f2007f74fa2d8f6b9296a5'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.30.0/buildx-v0.30.0.linux-arm-v7'; \
			sha256='d2a1b9a7b05d86b9f3b0b593edc2489b94ac9d27005966718374cd34cb840067'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.30.0/buildx-v0.30.0.linux-arm64'; \
			sha256='f8e060a1a1e659d1c919d440652775320e8c2998b051eb4b5845bfcee9d85696'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.30.0/buildx-v0.30.0.linux-ppc64le'; \
			sha256='1ad8ca464fdd5883c8b9c51294f21dac58f40acfab215371a35716c5aa1f78ee'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.30.0/buildx-v0.30.0.linux-riscv64'; \
			sha256='d0dcc7eda556022d03403af24d8044fcefb7daf5ddb7a11f9c154800919bfa2f'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.30.0/buildx-v0.30.0.linux-s390x'; \
			sha256='42f9615e3f812b4cbcec147923229ef7e404b7fe6107e10f196c7d10cdcac978'; \
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

ENV DOCKER_COMPOSE_VERSION 2.40.3
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-x86_64'; \
			sha256='dba9d98e1ba5bfe11d88c99b9bd32fc4a0624a30fafe68eea34d61a3e42fd372'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-armv6'; \
			sha256='cea4d6b6de410d220426806ef67ce7fadb4b914029f49a66fb222d4525ac6871'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-armv7'; \
			sha256='66aa2f460820b17aaa71e65b2c70e55eb27c11bdb9816169c322065a5b016d29'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-aarch64'; \
			sha256='d26373b19e89160546d15407516cc59f453030d9bc5b43ba7faf16f7b4980137'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-ppc64le'; \
			sha256='9be50cafe912442b27af48c44516b7ce2a65777ff121acf241dd5dba09d4f36c'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-riscv64'; \
			sha256='b52a2dcb0c221b5abd1d14729ed118aa24cf79012b5f2f992ddf6bc9c2e7f9fd'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.40.3/docker-compose-linux-s390x'; \
			sha256='3caf6694c974d13a2754689ffb8f93bc29d084ee60fb7f9ebd4b682264dad9fe'; \
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
