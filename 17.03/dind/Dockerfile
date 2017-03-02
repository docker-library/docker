FROM docker:17.03

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apk add --no-cache \
		btrfs-progs \
		e2fsprogs \
		e2fsprogs-extra \
		iptables \
		xfsprogs \
		xz

# TODO aufs-tools

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -x \
	&& addgroup -S dockremap \
	&& adduser -S -G dockremap dockremap \
	&& echo 'dockremap:165536:65536' >> /etc/subuid \
	&& echo 'dockremap:165536:65536' >> /etc/subgid

ENV DIND_COMMIT 3b5fac462d21ca164b3778647420016315289034

RUN wget "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -O /usr/local/bin/dind \
	&& chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
