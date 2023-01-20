#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.17

RUN apk add --no-cache \
		ca-certificates \
# Workaround for golang not producing a static ctr binary on Go 1.15 and up https://github.com/containerd/containerd/issues/5824
		libc6-compat \
# DOCKER_HOST=ssh://... -- https://github.com/docker/cli/pull/1014
		openssh-client

# ensure that nsswitch.conf is set up for Go's "netgo" implementation (which Docker explicitly uses)
# - https://github.com/moby/moby/blob/v20.10.21/hack/make.sh#L115
# - https://github.com/golang/go/blob/go1.19.3/src/net/conf.go#L227-L303
# - docker run --rm debian:stretch grep '^hosts:' /etc/nsswitch.conf
RUN [ -e /etc/nsswitch.conf ] && grep '^hosts: files dns' /etc/nsswitch.conf

ENV DOCKER_VERSION 20.10.23

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-20.10.23.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-20.10.23.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-20.10.23.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-20.10.23.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.10.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.0/buildx-v0.10.0.linux-amd64'; \
			sha256='f76047e43cd2526a870b9cf385effc7c9642c1a17d144559c43545525415867d'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.10.0/buildx-v0.10.0.linux-arm-v6'; \
			sha256='dc037b64e14388cbf5441d3b23a3f1ccd9a56a47007555ce681d89b70d411d31'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.10.0/buildx-v0.10.0.linux-arm-v7'; \
			sha256='19b82ba259d83cc75b12bddb1cdc0712dd276f8763d0a65ded2048193973260b'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.0/buildx-v0.10.0.linux-arm64'; \
			sha256='abf375431775d46139312591aa9471cdf6909d8a4e8392b73940ca136c34eb4d'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.10.0/buildx-v0.10.0.linux-ppc64le'; \
			sha256='9850f6ad445d1014a156c33ac7f9074fffd3358db304ef5b4e4509355a4d9fb9'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.10.0/buildx-v0.10.0.linux-riscv64'; \
			sha256='07529564e5b2f1f6e33fbf947700f9118a727dde2d8486c3e2115bc4fb42d86a'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.10.0/buildx-v0.10.0.linux-s390x'; \
			sha256='871b4a746765334a1a0b56700525d5ef7f83adcafbb193734e238c8ac102eccc'; \
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

ENV DOCKER_COMPOSE_VERSION 2.15.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-x86_64'; \
			sha256='bcfd9ea51dee4c19dccdfaeef0e7956ef68bf14f3d175933742061a7271ef0f5'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-armv6'; \
			sha256='a8934600100af88f535eb50b45c7d8d2ac37835221803ba2910e0b167b3af22e'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-armv7'; \
			sha256='e5b03ac1258ad4243af0ac4afcb1c6cc8c9956b2483a50309cdb38cdb8387e37'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-aarch64'; \
			sha256='14d31297794868520cb2e61b543bb1c821aaa484af22b397904314ae8227f6a2'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-ppc64le'; \
			sha256='bdada874a26d382b20ced7c170707a1ebcf9f20d7d6f394b962076968473ca9c'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-riscv64'; \
			sha256='9cc1b9c8de313a1e43b8f3dcca47c29eeb87af3de24c67448c463bf882166430'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.15.1/docker-compose-linux-s390x'; \
			sha256='cf311824af115d0bece5d5d60a73464912dad07cdd00fdaa469dabbcad60f289'; \
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
