#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker:19.03-dind

# busybox "ip" is insufficient:
#   [rootlesskit:child ] error: executing [[ip tuntap add name tap0 mode tap] [ip link set tap0 address 02:50:00:00:00:01]]: exit status 1
RUN apk add --no-cache iproute2

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
			url='https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-19.03.15.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-rootless-extras-19.03.15.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-rootless-extras-19.03.15.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-rootless-extras-19.03.15.tgz'; \
			;; \
		*) echo >&2 "error: unsupported architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O rootless.tgz "$url"; \
	\
	tar --extract \
		--file rootless.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		'docker-rootless-extras/rootlesskit' \
		'docker-rootless-extras/rootlesskit-docker-proxy' \
	; \
	rm rootless.tgz; \
	\
	rootlesskit --version

# We do not use vpnkit binary included in x86_64 version of docker-rootless-extras,
# because it is not available for other architectures and yet slower than slirp4netns.

ENV SLIRP4NETNS_VERSION 1.1.8
ENV SLIRP4NETNS_SHA256SUMS_SHA256 366f40a49c0cf25b7e2ee22e9fae6df575127aef75f968454f5705a1ff0784ff
RUN set -eux; \
  wget https://github.com/rootless-containers/slirp4netns/releases/download/v${SLIRP4NETNS_VERSION}/slirp4netns-$(uname -m); \
  wget https://github.com/rootless-containers/slirp4netns/releases/download/v${SLIRP4NETNS_VERSION}/SHA256SUMS; \
  echo "$SLIRP4NETNS_SHA256SUMS_SHA256  SHA256SUMS" | sha256sum -c -; \
  grep "slirp4netns-$(uname -m)" SHA256SUMS | sha256sum -c -; \
  mv slirp4netns-$(uname -m) /usr/local/bin/slirp4netns; \
  rm -f SHA256SUMS; \
  chmod +x /usr/local/bin/slirp4netns

# pre-create "/var/lib/docker" for our rootless user
RUN set -eux; \
	mkdir -p /home/rootless/.local/share/docker; \
	chown -R rootless:rootless /home/rootless/.local/share/docker
VOLUME /home/rootless/.local/share/docker
USER rootless
