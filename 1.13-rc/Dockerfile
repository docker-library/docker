FROM alpine:3.5

RUN apk add --no-cache \
		ca-certificates \
		curl \
		openssl

ENV DOCKER_BUCKET test.docker.com
ENV DOCKER_VERSION 1.13.0-rc6
ENV DOCKER_SHA256 8a5d299c5df3082d794b9741148a5ab386ffe7a5be6b737e36a2f5c70e005aae

RUN set -x \
	&& curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256} *docker.tgz" | sha256sum -c - \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz \
	&& docker -v

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
