FROM alpine:3.3

RUN apk add --no-cache curl

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.10.0
ENV DOCKER_SHA256 a66b20423b7d849aa8ef448b98b41d18c45a30bf3fe952cc2ba4760600b18087

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
