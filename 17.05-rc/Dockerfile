FROM alpine:3.5

RUN apk add --no-cache \
		ca-certificates \
		curl \
		openssl

ENV DOCKER_BUCKET test.docker.com
ENV DOCKER_VERSION 17.05.0-ce-rc1
ENV DOCKER_SHA256_x86_64 4561742c2174c01ffd0679621b66d29f8a504240d79aa714f6c58348979d02c6
ENV DOCKER_SHA256_armel 55da582c59e2f2ccebf74c661290ecdc4d503b53acff1644a85f1c1d60dfd661

RUN set -ex; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64) dockerArch=x86_64 ;; \
		armhf) dockerArch=armel ;; \
		*) echo >&2 "error: unknown Docker static binary arch $apkArch"; exit 1 ;; \
	esac; \
	curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/${dockerArch}/docker-${DOCKER_VERSION}.tgz" -o docker.tgz; \
# /bin/sh doesn't support ${!...} :(
	sha256="DOCKER_SHA256_${dockerArch}"; sha256="$(eval "echo \$${sha256}")"; \
	echo "${sha256} *docker.tgz" | sha256sum -c -; \
	tar -xzvf docker.tgz; \
	mv docker/* /usr/local/bin/; \
	rmdir docker; \
	rm docker.tgz; \
	docker -v

COPY docker-entrypoint.sh /usr/local/bin/

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh"]
