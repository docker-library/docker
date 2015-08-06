FROM alpine:3.2

RUN apk add --update \
		ca-certificates \
		openssl \
	&& rm -rf /var/cache/apk/*

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 1.0.1
ENV DOCKER_SHA256 1d9aea20ec8e640ec9feb6757819ce01ca4d007f208979e3156ed687b809a75b

RUN wget "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-$DOCKER_VERSION" -O /usr/local/bin/docker \
	&& echo "${DOCKER_SHA256}  /usr/local/bin/docker" | sha256sum -c - \
	&& chmod +x /usr/local/bin/docker

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
