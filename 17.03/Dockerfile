FROM alpine:3.5

RUN apk add --no-cache \
		ca-certificates \
		curl \
		openssl

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 17.03.1-ce
ENV DOCKER_SHA256_x86_64 820d13b5699b5df63f7032c8517a5f118a44e2be548dd03271a86656a544af55
ENV DOCKER_SHA256_armel f05c733c22915b0c26d8b0390b26a026b33aaf7593d15475a6f86e1bbe1ddbe2

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
