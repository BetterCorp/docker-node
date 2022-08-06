ARG NODE_C_VERSION=latest

FROM betterweb/alpine:latest

# Install python/pip - https://stackoverflow.com/a/62555259
ENV PYTHONUNBUFFERED=1
COPY node-gyp.sh /home/node-gyp.sh

RUN addgroup -g 1000 node && adduser -u 1000 -G node -s /bin/node -D node

RUN if command -v apk &> /dev/null ; then apk update && apk upgrade && apk add nodejs npm ; fi
#RUN if command -v apt &> /dev/null ; then apt update -y && apt upgrade -y ; fi
#RUN if command -v yum &> /dev/null ; then yum update -y && yum upgrade -y ; fi

RUN node --version && npm --version