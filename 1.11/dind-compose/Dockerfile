FROM docker:1.11-dind

RUN apk add --no-cache \
		'py-pip==8.1.2-r0'

RUN set -x \
	&& pip install 'docker-compose'

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375

ENTRYPOINT ["dockerd-entrypoint.sh"]
CMD []
