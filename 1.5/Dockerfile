FROM alpine:3.2

RUN apk add --update \
		ca-certificates \
		openssl \
	&& rm -rf /var/cache/apk/*

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.6.2
ENV DOCKER_SHA256 e131b2d78d9f9e51b0e5ca8df632ac0a1d48bcba92036d0c839e371d6cf960ec

RUN wget "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -O /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
