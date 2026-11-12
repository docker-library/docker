#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker:29-rc-cli

# Runtime dependencies:
# - https://github.com/moby/moby/blob/864598f8c2677189e308eb4a3b3c0dd41fc06599/project/PACKAGERS.md#runtime-dependencies#runtime-dependencies
# - https://github.com/docker/packaging/blob/0ba325d178593583f190dc91566214a85c3880ad/pkg/docker-engine/deb/control#L24-L36
RUN set -eux; \
	apk add --no-cache \
		ip6tables \
		iptables \
		openssl \
		pigz \
		shadow-uidmap \
		xz \
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
# https://pkgs.alpinelinux.org/contents?branch=v3.24&name=iptables-legacy&arch=x86_64
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
			url='https://download.docker.com/linux/static/test/x86_64/docker-29.10.0-rc.2.tgz'; \
			sha256='f6960ea6a13bbac1a4bfdde08b13d937753d82dd083d8f29a5f855e4d157e1ee'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/test/armel/docker-29.10.0-rc.2.tgz'; \
			sha256='69caab6e31d38ab4a0bfc2161d7284ea54d69a6f7d92747f03018d761ffd89f7'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/test/armhf/docker-29.10.0-rc.2.tgz'; \
			sha256='f0585679cc4214a6ba3c71a8def4386808de14e24b9d05f3a64e9e0107a7ae86'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/test/aarch64/docker-29.10.0-rc.2.tgz'; \
			sha256='cb4a05dd5a1f3f9812e7f2d122fdd8bea30cc182b98d9559a013573f2443474c'; \
			;; \
		'ppc64le') \
			url='https://download.docker.com/linux/static/test/ppc64le/docker-29.10.0-rc.2.tgz'; \
			sha256='b075ac18d0323a28e9189dcdbf1a8875803ff2cda55899041dddbed238ebbdfc'; \
			;; \
		's390x') \
			url='https://download.docker.com/linux/static/test/s390x/docker-29.10.0-rc.2.tgz'; \
			sha256='bf396b9a56b35e9bdc7c7b4eaa0049b4b4d9e82684e9317921763d5c4790cf1c'; \
			;; \
		*) echo >&2 "error: unsupported 'docker.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'docker.tgz' "$url"; \
	echo "$sha256 *"'docker.tgz' | sha256sum -c -; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		--no-same-owner \
# we exclude the CLI binary because we already extracted that over in the "docker:29-rc-cli" image that we're FROM and we don't want to duplicate those bytes again in this layer
		--exclude 'docker/docker' \
# exclude containerd, relying on the "embedded containerd" instead: https://github.com/moby/moby/pull/53388 (makes for a smaller image)
		--exclude 'docker/containerd' \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	ctr --version; \
	runc --version

# https://github.com/moby/moby/tree/master/hack/dind
ENV DIND_COMMIT 8d9e3502aba39127e4d12196dae16d306f76993d

RUN set -eux; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/moby/moby/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
