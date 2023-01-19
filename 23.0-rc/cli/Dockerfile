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

ENV DOCKER_VERSION 23.0.0-rc.2

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-23.0.0-rc.2.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-23.0.0-rc.2.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-23.0.0-rc.2.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-23.0.0-rc.2.tgz'; \
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

ENV DOCKER_COMPOSE_VERSION 2.15.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-x86_64'; \
			sha256='ba481d45be2b137a2a185abd05f61d6d7766dbedfa038f16e4705760767a206e'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-armv6'; \
			sha256='0f46aea568f35decc22e1db6af76decaf1c36b9bb374610bc08c3b3618170f8f'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-armv7'; \
			sha256='343b552c61d74446fc8e8ce7695f878cb2ad49f7fae98deb7fb76a37f24c251e'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-aarch64'; \
			sha256='634e397090ca0e857a898d853ab08d7e2f226328b305026c143c68d6ce0686de'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-ppc64le'; \
			sha256='236831ebb63ad30fe716bf22946c91e21b1277bff2785a8538e616168a0d93f1'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-riscv64'; \
			sha256='365d9bf34ae7a2ad0dc028d13363c8c427db1300b1335834a4e06b7e4fa412af'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-s390x'; \
			sha256='8072776b50f34d135f90c8118da60749435b2474afee3df96bbd9c95755f7a2f'; \
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
