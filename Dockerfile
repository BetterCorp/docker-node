ARG ALPINE_VERSION=3.19
ARG NODE_MAJOR=20
ARG NODE_VERSION=20.0.0
FROM node:${NODE_VERSION}-alpine AS builder

FROM betterweb/alpine:${ALPINE_VERSION}
COPY --from=builder /usr /usr
COPY install_packages.sh /usr/local/bin/install_packages
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/install_packages 
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "node" ]
