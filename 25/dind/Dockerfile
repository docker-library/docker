#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker:25-cli

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

# dind might be used on systems where the nf_tables kernel module isn't available. In that case,
# we need to switch over to xtables-legacy. See https://github.com/docker-library/docker/issues/463
RUN set -eux; \
	apk add --no-cache iptables-legacy; \
# set up a symlink farm we can use PATH to switch to legacy with
	mkdir -p /usr/local/sbin/.iptables-legacy; \
# https://git.alpinelinux.org/aports/tree/main/iptables/APKBUILD?id=b215d54de159eacafecb13c68dfadce6eefd9ec9#n73
	for f in \
		iptables \
		iptables-save \
		iptables-restore \
		ip6tables \
		ip6tables-save \
		ip6tables-restore \
	; do \
# "iptables-save" -> "iptables-legacy-save", "ip6tables" -> "ip6tables-legacy", etc.
# https://pkgs.alpinelinux.org/contents?branch=v3.19&name=iptables-legacy&arch=x86_64
		b="/sbin/${f/tables/tables-legacy}"; \
		"$b" --version; \
		ln -svT "$b" "/usr/local/sbin/.iptables-legacy/$f"; \
	done; \
# verify it works (and gets us legacy)
	export PATH="/usr/local/sbin/.iptables-legacy:$PATH"; \
	iptables --version | grep legacy

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
			url='https://download.docker.com/linux/static/stable/x86_64/docker-25.0.2.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-25.0.2.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-25.0.2.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-25.0.2.tgz'; \
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
# we exclude the CLI binary because we already extracted that over in the "docker:25-cli" image that we're FROM and we don't want to duplicate those bytes again in this layer
		--exclude 'docker/docker' \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	containerd --version; \
	ctr --version; \
	runc --version

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT 65cfcc28ab37cb75e1560e4b4738719c07c6618e

RUN set -eux; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
