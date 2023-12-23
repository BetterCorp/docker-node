ARG ALPINE_VERSION=3.19
ARG NODE_MAJOR=20
ARG NODE_VERSION=20.0.0
FROM node:${NODE_VERSION}-alpine AS builder

ENV GOSU_VERSION 1.17

RUN apk add --no-cache ca-certificates dpkg gnupg && \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" && \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu && \
    command -v gpgconf && gpgconf --kill all || : && \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu

# Second stage: copy only the gosu binary from the first stage

FROM node:${NODE_VERSION}-alpine
COPY --from=builder /usr/local/bin/gosu /usr/local/bin/gosu
COPY install_packages.sh /usr/local/bin/install_packages
RUN rm -f /usr/local/bin/docker-entrypoint.sh
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/install_packages 
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD [ "node" ]
