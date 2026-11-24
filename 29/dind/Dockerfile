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
			url='https://download.docker.com/linux/static/stable/x86_64/docker-engine_29.10.1.tgz'; \
			sha256='c530efff9498c33227043061563e390739bd4cee626a958357ea0abc0d53a2a0'; \
			;; \
		'armhf') \
			url='https://download.docker.com/linux/static/stable/armel/docker-engine_29.10.1.tgz'; \
			sha256='5d399af1c9f3f29ea4765c44b888bb7bbda9f254e8bf2230fa628e65a40f3e8c'; \
			;; \
		'armv7') \
			url='https://download.docker.com/linux/static/stable/armhf/docker-engine_29.10.1.tgz'; \
			sha256='55105b9e8da700112ed93f40199d58862f5376c85344cbeab0622b8c124a8756'; \
			;; \
		'aarch64') \
			url='https://download.docker.com/linux/static/stable/aarch64/docker-engine_29.10.1.tgz'; \
			sha256='7fbc252bfacb3685d244dfbef701048de7640eb981f24033623f0a3af4fc48b5'; \
			;; \
		'ppc64le') \
			url='https://download.docker.com/linux/static/stable/ppc64le/docker-engine_29.10.1.tgz'; \
			sha256='755c3d51f4377d9269f72198293f34e4ca8a58af7716085426c4f50c85d88fc1'; \
			;; \
		'riscv64') \
			url='https://download.docker.com/linux/static/stable/riscv64/docker-engine_29.10.1.tgz'; \
			sha256='09161e18d14c1cfea30e15f56a5535ebf0eef29fd641c8d70017ba21ad7ee873'; \
			;; \
		's390x') \
			url='https://download.docker.com/linux/static/stable/s390x/docker-engine_29.10.1.tgz'; \
			sha256='ff4e6aa4f1c513862667d52facea19da235b0704404d5a52dee27059e49ecc73'; \
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
# only "bin" (not the "doc" directory with a README and LICENSE we do not want in /usr/local/bin)
		'bin' \
	; \
	rm docker.tgz; \
	\
	dockerd --version

# the "embedded containerd" means we only need the shim and "ctr" from containerd (not the whole daemon): https://github.com/moby/moby/pull/53388 (makes for a smaller image)
RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/containerd/containerd/releases/download/v2.4.2/containerd-static-2.4.2-linux-amd64.tar.gz'; \
			sha256='da656542e754c699a0f438eab925e6ffdbd6346a4428e659f83dc058f04dcffe'; \
			;; \
		'aarch64') \
			url='https://github.com/containerd/containerd/releases/download/v2.4.2/containerd-static-2.4.2-linux-arm64.tar.gz'; \
			sha256='37b84b9534533672528141b9d815f58621a2fe5deee2daa84317800255756689'; \
			;; \
		'ppc64le') \
			url='https://github.com/containerd/containerd/releases/download/v2.4.2/containerd-static-2.4.2-linux-ppc64le.tar.gz'; \
			sha256='62e789018b9684b15c6cc0fa75566da7170b8cc9dc4655a91b637d8ec58e451a'; \
			;; \
		'riscv64') \
			url='https://github.com/containerd/containerd/releases/download/v2.4.2/containerd-static-2.4.2-linux-riscv64.tar.gz'; \
			sha256='9cc5ff951d351e7c9166486f7805be4e5ec1e9442113987700ba5218a18d205c'; \
			;; \
		's390x') \
			url='https://github.com/containerd/containerd/releases/download/v2.4.2/containerd-static-2.4.2-linux-s390x.tar.gz'; \
			sha256='cf4b70a6e74cacd6b06d909f7d16217f8ed10bffe32191197f3232e51c49fe86'; \
			;; \
		*) echo >&2 "error: unsupported 'containerd.tgz' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'containerd.tgz' "$url"; \
	echo "$sha256 *"'containerd.tgz' | sha256sum -c -; \
	\
	tar --extract \
		--file containerd.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
		--no-same-owner \
		'bin/containerd-shim-runc-v2' \
		'bin/ctr' \
	; \
	rm containerd.tgz; \
	\
	ctr --version

RUN set -eux; \
	\
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		'x86_64') \
			url='https://github.com/opencontainers/runc/releases/download/v1.5.3/runc.amd64'; \
			sha256='50dcc0b257d724fe07f3852c2dda52340223f038227c7572644eec870741223e'; \
			;; \
		'armhf') \
			url='https://github.com/opencontainers/runc/releases/download/v1.5.3/runc.armel'; \
			sha256='339e33a5ee914e902b938e8fdc3487110f240dd82f23fadefa53c169c2982d06'; \
			;; \
		'armv7') \
			url='https://github.com/opencontainers/runc/releases/download/v1.5.3/runc.armhf'; \
			sha256='411d8039888d71a167e6125f5bef2aef71f2ab80769c507cbeb7f51ba54f6392'; \
			;; \
		'aarch64') \
			url='https://github.com/opencontainers/runc/releases/download/v1.5.3/runc.arm64'; \
			sha256='07b52aee923cc432c38fe4fb6809a08fc6471994efed650af3635350588a20be'; \
			;; \
		'ppc64le') \
			url='https://github.com/opencontainers/runc/releases/download/v1.5.3/runc.ppc64le'; \
			sha256='e773f7c88e536edfbd690ce3aa4efb192beaeabeeaedf8dd4400aff91a97c028'; \
			;; \
		'riscv64') \
			url='https://github.com/opencontainers/runc/releases/download/v1.5.3/runc.riscv64'; \
			sha256='780dd7e9e269d94c759c8578ef030b18c8d22fc4a43b8209465d5e485015f9bb'; \
			;; \
		's390x') \
			url='https://github.com/opencontainers/runc/releases/download/v1.5.3/runc.s390x'; \
			sha256='159738a9e973b5c74aa9dec39845c36809d9dbf61fd2bc859f6a455436c17976'; \
			;; \
		*) echo >&2 "error: unsupported 'runc' architecture ($apkArch)"; exit 1 ;; \
	esac; \
	\
	wget -O 'runc' "$url"; \
	echo "$sha256 *"'runc' | sha256sum -c -; \
	\
	chmod +x runc; \
	mv -vT runc /usr/local/bin/runc; \
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
