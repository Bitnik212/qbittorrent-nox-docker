FROM node:16.19.0 as build-vue-theme

WORKDIR /tmp

RUN git clone https://github.com/WDaan/VueTorrent.git

WORKDIR /tmp/VueTorrent

RUN npm install

RUN npm run build

FROM alpine:3.16 as build-qbt

# Install required packages
RUN apk add --no-cache \
        boost \
        ca-certificates \
        curl \
        dumb-init \
        icu \
        libexecinfo \
        libtool \
        openssl \
        python3 \
        qt5-qtbase \
        qt5-qtsvg \
        qt5-qttools \
        re2c \
        zlib

# Compiling qBitTorrent following instructions on
# https://github.com/qbittorrent/qBittorrent/wiki/Compilation:-Alpine-Linux
RUN set -x \
    # Install build dependencies
 && apk add --no-cache -t .build-deps \
        autoconf \
        automake \
        boost-dev \
        build-base \
        cmake \
        git \
        libtool \
        linux-headers \
        perl \
        pkgconf \
        python3 \
        python3-dev \
        re2c \
        tar \
        icu-dev \
        libexecinfo-dev \
        openssl-dev \
        qt5-qtbase-dev \
        qt5-qttools-dev \
        zlib-dev \
        qt5-qtsvg-dev \
    # Build Ninja.
 && git clone --shallow-submodules --recurse-submodules https://github.com/ninja-build/ninja.git /tmp/ninja \
 && cd /tmp/ninja \
 && git checkout "$(git tag -l --sort=-v:refname "v*" | head -n 1)" \
 && cmake -Wno-dev -B build \
        -D CMAKE_CXX_STANDARD=17 \
        -D CMAKE_INSTALL_PREFIX="/usr/local" \
 && cmake --build build \
 && cmake --install build \
    # Boost build file.
 && curl -sNLk https://boostorg.jfrog.io/artifactory/main/release/1.76.0/source/boost_1_76_0.tar.gz -o "/tmp/boost_1_76_0.tar.gz" \
 && tar xf "/tmp/boost_1_76_0.tar.gz" -C /tmp \
    # Libtorrent
 && git clone --shallow-submodules --recurse-submodules https://github.com/arvidn/libtorrent.git /tmp/libtorrent \
 && cd /tmp/libtorrent \
 && git checkout "$(git tag -l --sort=-v:refname "v2*" | head -n 1)" \
 && cmake -Wno-dev -G Ninja -B build \
        -D CMAKE_BUILD_TYPE="Release" \
        -D CMAKE_CXX_STANDARD=17 \
        -D BOOST_INCLUDEDIR="$HOME/boost_1_76_0/" \
        -D CMAKE_INSTALL_LIBDIR="lib" \
        -D CMAKE_INSTALL_PREFIX="/usr/local" \
 && cmake --build build \
 && cmake --install build \
    # Build qBittorrent
 && git clone --shallow-submodules --recurse-submodules https://github.com/qbittorrent/qBittorrent.git /tmp/qbittorrent \
 && cd /tmp/qbittorrent \
 && git checkout "$(git tag -l --sort=-v:refname | head -n 1)" \
 && cmake -Wno-dev -G Ninja -B build \
        -D CMAKE_BUILD_TYPE="release" \
        -D GUI=off \
        -D CMAKE_CXX_STANDARD=17 \
        -D BOOST_INCLUDEDIR="$HOME/boost_1_76_0/" \
        -D CMAKE_CXX_STANDARD_LIBRARIES="/usr/lib/libexecinfo.so" \
        -D CMAKE_INSTALL_PREFIX="/usr/local" \
 && cmake --build build \
 && cmake --install build \
    # Clean-up
 && cd / \
 && apk del --purge .build-deps \
 && rm -rf /tmp/*

RUN set -x \
    # Add non-root user
 && adduser -S -D -u 520 -g 520 -s /sbin/nologin qbittorrent \
    # Create symbolic links to simplify mounting
 && mkdir -p /home/qbittorrent/.config/qBittorrent \
 && mkdir -p /home/qbittorrent/.local/share/qBittorrent \
 && mkdir /downloads \
 && ln -s /home/qbittorrent/.config/qBittorrent /config \
 && ln -s /home/qbittorrent/.local/share/qBittorrent /torrents \
 && chmod go+rw -R /home/qbittorrent /downloads /torrents \
    # Check it works
 && su qbittorrent -s /bin/sh -c 'qbittorrent-nox -v'

COPY qBittorrent.conf /config/qBittorrent.conf

ENV EMAIL_ENABLE="false" EMAIL_TO="" EMAIL_FROM="" EMAIL_SMTP="" EMAIL_PASSWORD="" EMAIL_LOGIN="" EMAIL_NEED_SSL="true" EMAIL_NEED_AUTH="true"

COPY entrypoint.sh /

COPY --from=build-vue-theme /tmp/VueTorrent/vuetorrent /home/qbittorrent/theme

RUN chmod +x entrypoint.sh

VOLUME ["/config", "/torrents", "/downloads"]

ENV HOME=/home/qbittorrent

USER qbittorrent

EXPOSE $QBT_WEB_PORT 8081

ENTRYPOINT ["/entrypoint.sh"]
CMD qbittorrent-nox --webui-port=$QBT_WEB_PORT

HEALTHCHECK --interval=5s --timeout=2s --retries=20 CMD curl --connect-timeout 15 --silent --show-error --fail http://localhost:$QBT_WEB_PORT/ >/dev/null || exit 1
