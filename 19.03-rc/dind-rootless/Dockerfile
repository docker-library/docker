FROM docker:19.03-rc-dind

RUN apk add --no-cache shadow-uidmap iproute2

ARG ROOTLESS_EXTRAS_URL=https://download.docker.com/linux/static/nightly/x86_64/docker-rootless-extras-0.0.0-20190710010648-0143db1.tgz
RUN mkdir -p /tmp/extras && \
 wget -O - $ROOTLESS_EXTRAS_URL | tar xzvf - -C /tmp/extras && \
 mv /tmp/extras/docker-rootless-extras/* /usr/local/bin && \
 rm -rf /tmp/extras
COPY dockerd-rootless-entrypoint.sh /usr/local/bin

ARG ROOTLESS_USER_ID=1000
ARG ROOTLESS_USER_SUBID_BEGIN=100000
ARG ROOTLESS_USER_SUBID_LENGTH=65536
RUN adduser -D -u $ROOTLESS_USER_ID user \
 && mkdir -p /run/user/$ROOTLESS_USER_ID /home/user/.local/share/docker \
 && chown -R user /run/user/$ROOTLESS_USER_ID /home/user \
 && echo user:$ROOTLESS_USER_SUBID_BEGIN:$ROOTLESS_USER_SUBID_LENGTH | tee /etc/subuid | tee /etc/subgid

USER user
ENV HOME /home/user
ENV USER user
ENV XDG_RUNTIME_DIR=/run/user/$ROOTLESS_USER_ID
ENV DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
VOLUME /home/user/.local/share/docker

ENTRYPOINT ["dockerd-rootless-entrypoint.sh"]
