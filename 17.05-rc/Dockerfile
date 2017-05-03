FROM alpine:3.5

RUN apk add --no-cache \
		ca-certificates \
		curl \
		openssl

ENV DOCKER_BUCKET test.docker.com
ENV DOCKER_VERSION 17.05.0-ce-rc3
ENV DOCKER_SHA256_x86_64 4cae10fab8860c824ae46d644cab08c088ee0f5b20b759f975ebf5e19ae7a83c
ENV DOCKER_SHA256_armel 8ac04d9f4a56af501c82d2a3df6dfe750eed351036b281ce78933cdb65373369

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
