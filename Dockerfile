FROM debian:jessie

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apt-get update && apt-get install -y \
		curl \
		\
		aufs-tools \
		btrfs-tools \
		ca-certificates \
		e2fsprogs \
		git \
		iptables \
		lxc \
		procps \
		xz-utils \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV DIND_COMMIT 723d43387a5c04ef8588c7e1557aa163e268581c

RUN curl -fL "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -o /usr/local/sbin/dind \
	&& chmod +x /usr/local/sbin/dind

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.6.0
ENV DOCKER_SHA256 526fbd15dc6bcf2f24f99959d998d080136e290bbb017624a5a3821b63916ae8

RUN curl -fL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

VOLUME /var/lib/docker
EXPOSE 2375

ENTRYPOINT ["dind"]
CMD ["docker", "--daemon", "--host=unix:///var/run/docker.sock", "--host=tcp://0.0.0.0:2375"]
