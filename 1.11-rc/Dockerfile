FROM alpine:3.3

RUN apk add --no-cache curl

ENV DOCKER_BUCKET test.docker.com
ENV DOCKER_VERSION 1.11.0-rc4
ENV DOCKER_SHA256 933d28b70dff2de839d7c332a4b9c645e2001afcd870fbd510f2880d1e222190

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
