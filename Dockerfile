FROM betterweb/alpine:latest AS builder

ARG NODE_VERSION=v20.0.0

# Install python/pip - https://stackoverflow.com/a/62555259
ENV PYTHONUNBUFFERED=1

RUN addgroup -g 1000 node \
    && adduser -u 1000 -G node -s /bin/sh -D node \
    && apk add --no-cache \
        libstdc++ \
    && apk add --no-cache --virtual .build-deps \
        curl \
    && ARCH= OPENSSL_ARCH='linux*' && alpineArch="$(apk --print-arch)" \
      && case "${alpineArch##*-}" in \
        x86_64) ARCH='x64' DOWNLOAD="YES" OPENSSL_ARCH=linux-x86_64;; \
        x86) OPENSSL_ARCH=linux-elf;; \
        aarch64) OPENSSL_ARCH=linux-aarch64;; \
        arm*) OPENSSL_ARCH=linux-armv4;; \
        ppc64le) OPENSSL_ARCH=linux-ppc64le;; \
        s390x) OPENSSL_ARCH=linux-s390x;; \
        *) ;; \
      esac \
  && if [ -n "${DOWNLOAD}" ]; then \
    set -eu; \
    curl -fsSLO --compressed "https://unofficial-builds.nodejs.org/download/release/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz"; \
      && tar -xJf "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
      && ln -s /usr/local/bin/node /usr/local/bin/nodejs; \
  else \
    echo "Building from source" \
    # backup build
    && apk add --no-cache --virtual .build-deps-full \
        binutils-gold \
        g++ \
        gcc \
        gnupg \
        libgcc \
        linux-headers \
        make \
        python3 \
    # use pre-existing gpg directory, see https://github.com/nodejs/docker-node/pull/1895#issuecomment-1550389150
    && export GNUPGHOME="$(mktemp -d)" \
    # gpg keys listed at https://github.com/nodejs/node#release-keys
    && for key in \
      # Beth Griggs <bethanyngriggs@gmail.com>
      4ED778F539E3634C779C87C6D7062848A1AB005C \ 
      # Bryan English <bryan@bryanenglish.com>
      141F07595B7B3FFE74309A937405533BE57C7D57 \ 
      # Danielle Adams <adamzdanielle@gmail.com>
      74F12602B6F1C4E913FAA37AD3A89613643B6201 \ 
      # Juan José Arboleda <soyjuanarbol@gmail.com>
      DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \ 
      # Michaël Zasso <targos@protonmail.com>
      8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \ 
      # Myles Borins <myles.borins@gmail.com>
      C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \ 
      # RafaelGSS <rafael.nunu@hotmail.com>
      890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \ 
      # Richard Lau <rlau@redhat.com>
      C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \ 
      # Ruy Adorno <ruyadorno@hotmail.com>
      108F52B48DB57BB0CC439B2997B01419BD92F80A \
      # Ulises Gascón <ulisesgascongonzalez@gmail.com> 
      A363A499291CBBC940DD62E41F10027AF002F8B0 \
      # Chris Dickinson <christopher.s.dickinson@gmail.com>
      9554F04D7259F04124DE6B476D5A82AC7E37093B \ 
      # Colin Ihrig <cjihrig@gmail.com>
      94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \ 
      # Danielle Adams <adamzdanielle@gmail.com>
      1C050899334244A8AF75E53792EF661D867B9DFA \
      # Evan Lucas <evanlucas@me.com> 
      B9AE9905FFD7803F25714661B63B535A4C206CA9 \
      # Gibson Fahnestock <gibfahn@gmail.com>
      77984A986EBC2AA786BC0F66B01FBB92821C587A \
      # Isaac Z. Schlueter <i@izs.me> 
      93C7E9E91B49E432C2F75674B0A78B0A6C481CF6 \
      # Italo A. Casas <me@italoacasas.com>
      56730D5401028683275BD23C23EFEFE93C4CFFFE \
      # James M Snell <jasnell@keybase.io> 
      71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
      # Jeremiah Senkpiel <fishrock@keybase.io>
      FD3A5288F042B6850C66B31F09FE44734EB7990E \ 
      # Juan José Arboleda <soyjuanarbol@gmail.com>
      61FC681DFB92A079F1685E77973F295594EC4689 \ 
      # Julien Gilli <jgilli@fastmail.fm>
      114F43EE0176B71C7BC219DD50A3051F888C628D \ 
      # Rod Vagg <rod@vagg.org>
      DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
      # Ruben Bridgewater <ruben@bridgewater.de> 
      A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
      # Shelley Vohr <shelley.vohr@gmail.com>
      B9E2F5981AA6E0CD28160D9FF13993A75599653C \ 
      # Timothy J Fontaine <tjfontaine@gmail.com>
      7937DFD2AB06298B2293C3187D33FF9D0246406D \ 
    ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
    done \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.xz" \
    && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
    && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && grep " node-v$NODE_VERSION.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xf "node-v$NODE_VERSION.tar.xz" \
    && cd "node-v$NODE_VERSION" \
    && ./configure \
    && make -j$(getconf _NPROCESSORS_ONLN) V= \
    && make install \
    && apk del .build-deps-full \
    && cd .. \
    && rm -Rf "node-v$NODE_VERSION" \
    && rm "node-v$NODE_VERSION.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt; \
  fi \
  && rm -f "node-v$NODE_VERSION-linux-$ARCH-musl.tar.xz" \
  # Remove unused OpenSSL headers to save ~34MB. See this NodeJS issue: https://github.com/nodejs/node/issues/46451
  && find /usr/local/include/node/openssl/archs -mindepth 1 -maxdepth 1 ! -name "$OPENSSL_ARCH" -exec rm -rf {} \; \
  && apk del .build-deps \
  # smoke tests
  && node --version \
  && npm --version

FROM betterweb/alpine:latest
COPY --from=builder /usr/local /usr/local
COPY install_packages.sh /usr/local/bin/install_packages
COPY docker-entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh /usr/local/bin/install_packages 
ENTRYPOINT ["/entrypoint.sh"]
CMD [ "node" ]
