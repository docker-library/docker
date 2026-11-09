#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker:29-rc-dind

# busybox "ip" is insufficient:
#   [rootlesskit:child ] error: executing [[ip tuntap add name tap0 mode tap] [ip link set tap0 address 02:50:00:00:00:01]]: exit status 1
# slirp4netns is recommended as rootlesskit's net driver
# https://github.com/rootless-containers/rootlesskit/blob/be156df0429551f5c23dc61dd07201b33076ff1d/docs/network.md#--netslirp4netns-recommended
RUN apk add --no-cache iproute2 fuse-overlayfs slirp4netns

# "/run/user/UID" will be used by default as the value of XDG_RUNTIME_DIR
RUN mkdir /run/user && chmod 1777 /run/user

# create a default user preconfigured for running rootless dockerd
RUN set -eux; \
	adduser -h /home/rootless -g 'Rootless' -D -u 1000 rootless; \
	echo 'rootless:100000:65536' >> /etc/subuid; \
	echo 'rootless:100000:65536' >> /etc/subgid

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/test/x86_64/docker-rootless-extras-29.10.0-rc.1.tgz'; \
			sha256='e63ea3c6e4a28575be61bae88303b335c9637198d79a1b1aaae17ad0f955abc9'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-rootless-extras-29.10.0-rc.1.tgz'; \
			sha256='2db6e2f180b66a4b5f6555f56041c85e55537230aaf939fdf18d60e1cea59c9e'; \
			;; \
		*) echo >&2 "error: unsupported 'rootless.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'rootless.tgz' "$url"; \
	if [ -n "${sha256:-}" ]; then \
		echo "$sha256 *"'rootless.tgz' | sha256sum -c -; \
	fi; \
	\
	tar --extract \
		--file rootless.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		'docker-rootless-extras/rootlesskit' \
	; \
	rm rootless.tgz; \
	\
	rootlesskit --version

# pre-create "/var/lib/docker" for our rootless user
RUN set -eux; \
	mkdir -p /home/rootless/.local/share/docker; \
	chown -R rootless:rootless /home/rootless/.local/share/docker
VOLUME /home/rootless/.local/share/docker
USER rootless
