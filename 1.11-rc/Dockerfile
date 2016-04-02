FROM alpine:3.3

RUN apk add --no-cache curl

ENV DOCKER_BUCKET test.docker.com
ENV DOCKER_VERSION 1.11.0-rc3
ENV DOCKER_SHA256 2c54dec1480d84a3b65007b4c2c4c75d0a96589159919798ffe402aebb98085e

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
