FROM alpine:3.3

RUN apk add --no-cache curl

ENV DOCKER_BUCKET test.docker.com
ENV DOCKER_VERSION 1.11.0-rc5
ENV DOCKER_SHA256 c18e16417c3c430d9b15f3a24112f3612ba89f511da2a2b9809e1a58324d2ff3

RUN set -x \
	&& curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz \
	&& docker -v

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
