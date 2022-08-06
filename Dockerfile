ARG NODE_C_VERSION=latest

FROM node:$NODE_C_VERSION

# Install python/pip - https://stackoverflow.com/a/62555259
ENV PYTHONUNBUFFERED=1

COPY node-gyp.sh /home/node-gyp.sh