#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker:24-cli

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN set -eux; \
	apk add --no-cache \
		btrfs-progs \
		e2fsprogs \
		e2fsprogs-extra \
		ip6tables \
		iptables \
		openssl \
		shadow-uidmap \
		xfsprogs \
		xz \
# pigz: https://github.com/moby/moby/pull/35697 (faster gzip implementation)
		pigz \
	; \
# only install zfs if it's available for the current architecture
# https://git.alpinelinux.org/cgit/aports/tree/main/zfs/APKBUILD?h=3.6-stable#n9 ("all !armhf !ppc64le" as of 2017-11-01)
# "apk info XYZ" exits with a zero exit code but no output when the package exists but not for this arch
	if zfs="$(apk info --no-cache --quiet zfs)" && [ -n "$zfs" ]; then \
		apk add --no-cache zfs; \
	fi

# TODO aufs-tools

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -eux; \
	addgroup -S dockremap; \
	adduser -S -G dockremap dockremap; \
	echo 'dockremap:165536:65536' >> /etc/subuid; \
	echo 'dockremap:165536:65536' >> /etc/subgid

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://download.docker.com/linux/static/stable/x86_64/docker-24.0.7.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-24.0.7.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-24.0.7.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-24.0.7.tgz'; \
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
# we exclude the CLI binary because we already extracted that over in the "docker:24-cli" image that we're FROM and we don't want to duplicate those bytes again in this layer
		--exclude 'docker/docker' \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	containerd --version; \
	ctr --version; \
	runc --version

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT d58df1fc6c866447ce2cd129af10e5b507705624

RUN set -eux; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
