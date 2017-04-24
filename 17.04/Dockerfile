FROM alpine:3.5

RUN apk add --no-cache \
		ca-certificates \
		curl \
		openssl

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 17.04.0-ce
ENV DOCKER_SHA256_x86_64 c52cff62c4368a978b52e3d03819054d87bcd00d15514934ce2e0e09b99dd100
ENV DOCKER_SHA256_armel 9b7df7dc02f620748657d3f599a9701c35f7b0b3d0acbc7fd324126ba5f6c4e9

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
