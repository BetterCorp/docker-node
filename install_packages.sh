#!/bin/sh

function install_packages() {
    apk add --no-cache --virtual .gyp python make g++ \
    && npm install $1 \
    && apk del .gyp
}

# Call the function with your npm dependencies
#install_packages "[your npm dependencies here]"
