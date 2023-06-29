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

ENV DOCKER_VERSION 24.0.2

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-24.0.2.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-24.0.2.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-24.0.2.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-24.0.2.tgz'; \
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

ENV DOCKER_COMPOSE_VERSION 2.19.1
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-x86_64'; \
			sha256='8d3ecd3e48c598ba2e2d8eb3b59380f74c8c0c46259008fcd16d0dc058aaebd1'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-armv6'; \
			sha256='78639fa8323f0f60cd8b45a882bbb63cc630b44a7187e922195855cb64607d8f'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-armv7'; \
			sha256='bc9646ecf835e5e2665b7de6455c07cb21d4e892a4c212f9ca9f3024a26ff880'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-aarch64'; \
			sha256='35db0e5207c66e002bfde3cab84e907aa7e552812803bebebf990487729eb2bf'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-ppc64le'; \
			sha256='9c79eada1314e63734eb33e9d1815b5f494c357b45ac1c3ec035188ee616f215'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-riscv64'; \
			sha256='bcca185b3f1f2e6dbb392149f52676075b1e42ba64a3ed6508c2f9fc1b60c634'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v2.19.1/docker-compose-linux-s390x'; \
			sha256='152e40b9f600b84223b8c2f217c45ed4813af8cdd98017cdcbdb35b81423f8d9'; \
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
