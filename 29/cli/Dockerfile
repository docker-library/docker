#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM alpine:3.24

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

ENV DOCKER_VERSION 29.7.1

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.7.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.7.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.7.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.7.1.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.36.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.36.0/buildx-v0.36.0.linux-amd64'; \
			sha256='07823fdfcd82a41be90155a8b16876c1a780a6462de805a9f3f63b3119ccfb99'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.36.0/buildx-v0.36.0.linux-arm-v6'; \
			sha256='6d87680eab65cb2b8c3bba602406a40f718b77eb8e3af10994db794e3deada37'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.36.0/buildx-v0.36.0.linux-arm-v7'; \
			sha256='50527239ba76f72e9ffd8227a2e265c6751f71e4908546f0f68c329e87b2c71c'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.36.0/buildx-v0.36.0.linux-arm64'; \
			sha256='70382de03915c07c488ae4ddc4f7e169ee978f953e754ecfce110ba017e0132b'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.36.0/buildx-v0.36.0.linux-ppc64le'; \
			sha256='ebd3c6c77e649c759986380e1281d38b50bd4afe88fec2076ea48c56b1e08227'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.36.0/buildx-v0.36.0.linux-riscv64'; \
			sha256='8b2b242d512e77f711028af53f8501241fceb22a80a8f5e7368a27375cf805a7'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.36.0/buildx-v0.36.0.linux-s390x'; \
			sha256='7c00dc2644ff428779d075aa080d046397511797d1c8475dce9f3c3471965a04'; \
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

ENV DOCKER_COMPOSE_VERSION 5.4.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.4.0/docker-compose-linux-x86_64'; \
			sha256='837fd1d35bf6a494f41b5b5988269a7be79de337cf1a1a6ff0e45ab51bb4e9be'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.4.0/docker-compose-linux-armv6'; \
			sha256='a5832fe8544e6e72af7cc380a2e3c014a6ced6d56db12fe814d40ffd0e657a6d'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.4.0/docker-compose-linux-armv7'; \
			sha256='f0c92550db24083a2622e4e980a3fdc13890125962ca09590a86c87ad0b3c536'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.4.0/docker-compose-linux-aarch64'; \
			sha256='fc5d1371f1ec7987e703da94ede49af3fbfb240b83f22991a98511de7bc4b93b'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.4.0/docker-compose-linux-ppc64le'; \
			sha256='8158968c7ddb298ae901024c5fb6d471454d1bd75bdea317c4a9d24f87fa4868'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.4.0/docker-compose-linux-riscv64'; \
			sha256='016b7ac25ce605575bab99464d6b63141c41e14cc49cd0fa19c82aa8dd75a004'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.4.0/docker-compose-linux-s390x'; \
			sha256='892b60ad432d526b80376ba0b15429c6849ccc598b50b657aa6339310110a85a'; \
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
