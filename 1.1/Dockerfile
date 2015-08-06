FROM alpine:3.2

RUN apk add --update \
		ca-certificates \
		openssl \
	&& rm -rf /var/cache/apk/*

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.1.2
ENV DOCKER_SHA256 decb1698c1001ce148c975dbb0da1e39d19adbaad076d8c04edbf0b9e719954c

RUN wget "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -O /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
