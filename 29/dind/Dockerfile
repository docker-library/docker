#
# NOTE: THIS DOCKERFILE IS GENERATED VIA "apply-templates.sh"
#
# PLEASE DO NOT EDIT IT DIRECTLY.
#

FROM docker:29-cli

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
			url='https://download.docker.com/linux/static/stable/x86_64/docker-29.10.1.tgz'; \
			sha256='061642059fa7f2ed9b2f04a327a951cff4249585cf04b2661c2a6539197c9962'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-29.10.1.tgz'; \
			sha256='0a5d05059d3d82099a35ec7326120f4789f43b1b238ecc318242b178b986f09c'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-29.10.1.tgz'; \
			sha256='64e904668b30def335d933d5318b6310927a90a68570073d81741af78e71b1fd'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-29.10.1.tgz'; \
			sha256='a38c8a9ef6d17bce07499bfd3a3688542274769dc3b4f75c06ea2705fe65053e'; \
			;; \
		'ppc64le') \
			url='https://download.docker.com/linux/static/stable/ppc64le/docker-29.10.1.tgz'; \
			sha256='431f36bea426544239e95019e85a1d491b1b4817fd393fc5258fb2f000577791'; \
			;; \
		'riscv64') \
			url='https://download.docker.com/linux/static/stable/riscv64/docker-29.10.1.tgz'; \
			sha256='f30e9d9f642feaf4bc175d8c114f4b0bd4fa0032f2352ffbc1d3269592b9c6bf'; \
			;; \
		's390x') \
			url='https://download.docker.com/linux/static/stable/s390x/docker-29.10.1.tgz'; \
			sha256='c161754580a9e74a8af85a78b9ee7c79a5971676c28113b88f117cafd8036728'; \
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
# we exclude the CLI binary because we already extracted that over in the "docker:29-cli" image that we're FROM and we don't want to duplicate those bytes again in this layer
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
