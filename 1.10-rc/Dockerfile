FROM alpine:3.3

RUN apk add --no-cache curl

ENV DOCKER_BUCKET test.docker.com
ENV DOCKER_VERSION 1.10.0-rc2
ENV DOCKER_SHA256 9d9ee3ec6d1724c4c9459230583c611b76d2a2483595e1d4d6361b06d447bd3e

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
