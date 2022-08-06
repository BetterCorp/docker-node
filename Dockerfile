ARG NODE_C_VERSION=latest

FROM node:$NODE_C_VERSION

# Install python/pip - https://stackoverflow.com/a/62555259
ENV PYTHONUNBUFFERED=1

RUN if command -v apk &> /dev/null ; then apk update && apk upgrade ; fi
RUN if command -v apt &> /dev/null ; then apt update -y && apt upgrade -y ; fi
RUN if command -v yum &> /dev/null ; then yum update -y && yum upgrade -y ; fi

COPY node-gyp.sh /home/node-gyp.sh