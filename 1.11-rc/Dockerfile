FROM alpine:3.3

RUN apk add --no-cache curl

ENV DOCKER_BUCKET test.docker.com
ENV DOCKER_VERSION 1.11.0-rc2
ENV DOCKER_SHA256 6186327760028e06e0639df980a25da827451b9360a1b8ae88636f26ea392b20

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o /usr/local/bin/docker.tgz \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker.tgz" | sha256sum -c - \
# https://github.com/docker/docker/pull/21625
	&& tar -xzvf /usr/local/bin/docker.tgz -C / \
	&& docker -v

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
