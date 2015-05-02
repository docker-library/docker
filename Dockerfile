FROM debian:jessie

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN apt-get update && apt-get install -y \
		curl \
		ca-certificates \
	--no-install-recommends && rm -rf /var/lib/apt/lists/*

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.6.0
ENV DOCKER_SHA256 526fbd15dc6bcf2f24f99959d998d080136e290bbb017624a5a3821b63916ae8

RUN curl -fL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker
