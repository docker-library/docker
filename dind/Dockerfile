FROM docker:1.6.0

ENV DIND_COMMIT ac20568b0a62c794c0f1190703f051bd1cfac341

RUN curl -fL "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind" -o /usr/local/sbin/dind \
	&& chmod +x /usr/local/sbin/dind

VOLUME /var/lib/docker
EXPOSE 2375

ENTRYPOINT ["dind"]
CMD ["docker", "--daemon", "--host=unix:///var/run/docker.sock", "--host=tcp://0.0.0.0:2375"]
