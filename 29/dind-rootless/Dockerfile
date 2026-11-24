#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker:29-dind

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
			url='https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-29.10.1.tgz'; \
			sha256='11eb5fa9a88e5971e71713aa277dbd916b7d368c6625844cacffa1c42b8df60c'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-rootless-extras-29.10.1.tgz'; \
			sha256='976e508d9a256322921948933798732c7b2eca875dcd8182678468b57572be0a'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-rootless-extras-29.10.1.tgz'; \
			sha256='be4c104a5b99b568671bdf29be129fcb23a08f9f0c7e3fcacd311a4593cfbff7'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-rootless-extras-29.10.1.tgz'; \
			sha256='9b677eb3bb0ce21c4e6aae3e44678309250f1aa6fbc95f66a94de7b88b04e45b'; \
			;; \
		'ppc64le') \
			url='https://download.docker.com/linux/static/stable/ppc64le/docker-rootless-extras-29.10.1.tgz'; \
			sha256='725aeeb0858684127197ca8bb5fc2a8132f1adb4a2597dd9502fd954d39a5ed0'; \
			;; \
		'riscv64') \
			url='https://download.docker.com/linux/static/stable/riscv64/docker-rootless-extras-29.10.1.tgz'; \
			sha256='8e7aa270a82cdf4ae7b96f3672053cf65617da2a575e636d0e51d03a846fe0c2'; \
			;; \
		's390x') \
			url='https://download.docker.com/linux/static/stable/s390x/docker-rootless-extras-29.10.1.tgz'; \
			sha256='2e39dfd4130d0eb6b2cc3935672e557aca9cea354f3ffc96a186ecb5c4786771'; \
			;; \
		*) echo >&2 "error: unsupported 'rootless.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'rootless.tgz' "$url"; \
	echo "$sha256 *"'rootless.tgz' | sha256sum -c -; \
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
