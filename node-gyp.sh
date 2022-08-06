#!/bin/sh

if command -v apk &> /dev/null ; then apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python ; fi

python3 -m ensurepip
pip3 install --no-cache --upgrade pip setuptools

npm install -g node-gyp
