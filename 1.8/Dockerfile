FROM alpine:3.2

RUN apk add --update \
		curl \
	&& rm -rf /var/cache/apk/*

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.8.2
ENV DOCKER_SHA256 97a3f5924b0b831a310efa8bf0a4c91956cd6387c4a8667d27e2b2dd3da67e4d

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
