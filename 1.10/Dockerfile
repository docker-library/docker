FROM alpine:3.3

RUN apk add --no-cache curl

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.10.1
ENV DOCKER_SHA256 de4057057acd259ec38b5244a40d806993e2ca219e9869ace133fad0e09cedf2

RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -o /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
