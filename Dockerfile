ARG NODE_C_VERSION=latest

FROM node:$NODE_C_VERSION

# Install python/pip - https://stackoverflow.com/a/62555259
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

RUN npm install -g node-gyp