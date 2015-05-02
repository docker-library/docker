FROM docker:1.6.0

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apt-get update && apt-get install -y \
		aufs-tools \
		btrfs-tools \
		e2fsprogs \
		iptables \
		procps \
		xz-utils \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV DIND_COMMIT ac20568b0a62c794c0f1190703f051bd1cfac341

RUN curl -fL "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -o /usr/local/sbin/dind \
	&& chmod +x /usr/local/sbin/dind

VOLUME /var/lib/docker
EXPOSE 2375

ENTRYPOINT ["dind"]
CMD ["docker", "--daemon", "--host=unix:///var/run/docker.sock", "--host=tcp://0.0.0.0:2375"]
