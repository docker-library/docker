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

ENV DOCKER_VERSION 29.9.0-rc.2

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-29.9.0-rc.2.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-29.9.0-rc.2.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-29.9.0-rc.2.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-29.9.0-rc.2.tgz'; \
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

ENV DOCKER_BUILDX_VERSION 0.38.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/buildx/releases/download/v0.38.0/buildx-v0.38.0.linux-amd64'; \
			sha256='4fe4cc38adf48169132749b6ca22a990928db0118e3407584ee553723115d287'; \
			;; \
		'armhf') \
			url='https://github.com/docker/buildx/releases/download/v0.38.0/buildx-v0.38.0.linux-arm-v6'; \
			sha256='b4ac29bafc49598dbbb72c02fea69f4c89564cfd83de075ce591823d8ddd9a16'; \
			;; \
		'armv7') \
			url='https://github.com/docker/buildx/releases/download/v0.38.0/buildx-v0.38.0.linux-arm-v7'; \
			sha256='70e58bea42b5ecbda36aa3fa7328856e2478c34dada2787a6f44663c15421eb7'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/buildx/releases/download/v0.38.0/buildx-v0.38.0.linux-arm64'; \
			sha256='38e890e1a162bfdbf32fbe91404991dc4fc28e55b0de901b34374a061bab4d2c'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/buildx/releases/download/v0.38.0/buildx-v0.38.0.linux-ppc64le'; \
			sha256='252245e57c2648cabdfd4d2c5d21c03dfd039cad2ec2050435466c701b8dfed6'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/buildx/releases/download/v0.38.0/buildx-v0.38.0.linux-riscv64'; \
			sha256='b6fd16e37b3b370220ba0e616ba8013f45c915904249c0e2cb3ee9cfb6fc0868'; \
			;; \
		's390x') \
			url='https://github.com/docker/buildx/releases/download/v0.38.0/buildx-v0.38.0.linux-s390x'; \
			sha256='4c5c1de5059063e51c15c51cd87279aa2248ffbded7e16fe3086e83f3337037b'; \
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

ENV DOCKER_COMPOSE_VERSION 5.6.0
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/docker/compose/releases/download/v5.6.0/docker-compose-linux-x86_64'; \
			sha256='40343e21ca777173e69cff5dbafeb37c6f81f3b0d57d9e597f036e95eb63e76a'; \
			;; \
		'armhf') \
			url='https://github.com/docker/compose/releases/download/v5.6.0/docker-compose-linux-armv6'; \
			sha256='5531d2b21378cd0600d78c0ff44425fdcc2c0ba3b424a2e683004ff7987a4b53'; \
			;; \
		'armv7') \
			url='https://github.com/docker/compose/releases/download/v5.6.0/docker-compose-linux-armv7'; \
			sha256='7bce2792fb474aa3bbb67ee7060622eb0f66516c92083712bdec520127d4f105'; \
			;; \
		'aarch64') \
			url='https://github.com/docker/compose/releases/download/v5.6.0/docker-compose-linux-aarch64'; \
			sha256='733ec76717ceb59052a9609b9dadfb523b2df8eab57a54212872d10a58078ea2'; \
			;; \
		'ppc64le') \
			url='https://github.com/docker/compose/releases/download/v5.6.0/docker-compose-linux-ppc64le'; \
			sha256='59893abdb92b6f23ed105f82472ba8df92e688916186b8622c4ebdf7abbf9984'; \
			;; \
		'riscv64') \
			url='https://github.com/docker/compose/releases/download/v5.6.0/docker-compose-linux-riscv64'; \
			sha256='ea7702b8ac29d2b84bf05dc31727d5eceb3bd46f36ea30725b7532d4e3d8ae43'; \
			;; \
		's390x') \
			url='https://github.com/docker/compose/releases/download/v5.6.0/docker-compose-linux-s390x'; \
			sha256='c1ed074ea3854870272a8d988e2f87ca7be0299aa51ad4ad024ef02cf5c273e1'; \
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
