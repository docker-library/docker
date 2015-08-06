FROM alpine:3.2

RUN apk add --update \
		ca-certificates \
		openssl \
	&& rm -rf /var/cache/apk/*

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.2.0
ENV DOCKER_SHA256 0b69c75902f1cb71a3595fdf187f6288eaf36724d5484d3b9e3d852be53ba134

RUN wget "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -O /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
