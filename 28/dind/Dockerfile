#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker:28-cli

# https://github.com/moby/moby/blob/0eecd59153c03ced5f5ddd79cc98f29e4d86daec/project/PACKAGERS.md#runtime-dependencies
# https://github.com/docker/docker-ce-packaging/blob/963aa02666035d4e268f33c63d7868d6cdd1d34c/deb/common/control#L28-L41
RUN set -eux; \
	apk add --no-cache \
		btrfs-progs \
		e2fsprogs \
		e2fsprogs-extra \
		git \
		ip6tables \
		iptables \
		openssl \
		pigz \
		shadow-uidmap \
		xfsprogs \
		xz \
		zfs \
	;

# dind might be used on systems where the nf_tables kernel module isn't available. In that case,
# we need to switch over to xtables-legacy. See https://github.com/docker-library/docker/issues/463
RUN set -eux; \
	apk add --no-cache iptables-legacy; \
# set up a symlink farm we can use PATH to switch to legacy with
	mkdir -p /usr/local/sbin/.iptables-legacy; \
# https://gitlab.alpinelinux.org/alpine/aports/-/blob/a7e1610a67a46fc52668528efe01cee621c2ba6c/main/iptables/APKBUILD#L77
	for f in \
		iptables \
		iptables-save \
		iptables-restore \
		ip6tables \
		ip6tables-save \
		ip6tables-restore \
	; do \
# "iptables-save" -> "iptables-legacy-save", "ip6tables" -> "ip6tables-legacy", etc.
# https://pkgs.alpinelinux.org/contents?branch=v3.22&name=iptables-legacy&arch=x86_64
		b="$(command -v "${f/tables/tables-legacy}")"; \
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
			url='https://download.docker.com/linux/static/stable/x86_64/docker-28.5.1.tgz'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-28.5.1.tgz'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-28.5.1.tgz'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-28.5.1.tgz'; \
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
# we exclude the CLI binary because we already extracted that over in the "docker:28-cli" image that we're FROM and we don't want to duplicate those bytes again in this layer
		--exclude 'docker/docker' \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	containerd --version; \
	ctr --version; \
	runc --version

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT 8d9e3502aba39127e4d12196dae16d306f76993d

RUN set -eux; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
