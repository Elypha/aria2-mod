# Dockerfile to build aria2 binary with debian
#
# docker build -t aria2-build - < aria2.dockerfile
#
# After build, binary is at '/build/aria2c'
# You may extract the binary using following commands:
#
# id=$(docker create aria2-build)
# docker cp $id:/build/aria2c .
# docker rm -v $id
# docker image prune

FROM debian:12

LABEL MAINTAINER "Elypha"

ENV DEBIAN_FRONTEND noninteractive

ENV URL_zlib       "https://www.zlib.net/zlib-1.2.13.tar.gz"
ENV URL_expat      "https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.bz2"
ENV URL_c_ares     "https://c-ares.org/download/c-ares-1.19.1.tar.gz"
ENV URL_openssl    "https://www.openssl.org/source/openssl-1.1.1u.tar.gz"
ENV URL_sqlite3    "https://www.sqlite.org/2023/sqlite-autoconf-3420000.tar.gz"
ENV URL_libssh2    "https://www.libssh2.org/download/libssh2-1.11.0.tar.gz"

ENV DIR_root      "/build"
ENV DIR_zlib      "$DIR_root/zlib"
ENV DIR_expat     "$DIR_root/libexpat"
ENV DIR_c_ares    "$DIR_root/c_ares"
ENV DIR_openssl   "$DIR_root/openssl"
ENV DIR_sqlite3   "$DIR_root/sqlite3"
ENV DIR_libssh2   "$DIR_root/libssh2"
ENV DIR_aria2     "$DIR_root/aria2"
ENV DIR_patch     "$DIR_root/patch"
ENV DIR_prefix    "$DIR_root/deps"

ENV CC      "gcc"
ENV CXX     "g++"
ENV AR      "ar"
ENV LD      "ld"
ENV RANLIB  "ranlib"
ENV STRIP   "strip"

ENV LD_LIBRARY_PATH  "$DIR_prefix/lib"
ENV PKG_CONFIG_PATH: "$DIR_prefix/lib/pkgconfig"
ENV CURL_CA_BUNDLE   "/etc/ssl/certs/ca-certificates.crt"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        curl \
        ca-certificates \
        libxml2-dev \
        libcppunit-dev \
        autoconf \
        automake \
        autotools-dev \
        autopoint \
        libtool \
        pkg-config

RUN mkdir -p $DIR_zlib && cd $DIR_zlib && \
    curl -Ls -o - "$URL_zlib" | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --static && \
    make -j$(nproc) && \
    make install

RUN mkdir -p $DIR_expat && cd $DIR_expat && \
    curl -Ls -o - "$URL_expat" | tar jxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --enable-static \
        --disable-shared \
        --without-examples \
        --without-tests \
        --without-docbook && \
    make install -j$(nproc)

RUN mkdir -p $DIR_c_ares && cd $DIR_c_ares && \
    curl -Ls -o - "$URL_c_ares" | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --enable-static \
        --disable-shared \
        --disable-tests && \
    make install -j$(nproc)

RUN mkdir -p $DIR_openssl && cd $DIR_openssl && \
    curl -Ls -o - "$URL_openssl" | tar zxf - --strip-components=1 && \
    ./Configure \
        --prefix=$DIR_prefix \
        "linux-x86_64" \
        no-tests && \
    make install_sw
    # make install_sw -j$(nproc)

RUN mkdir -p $DIR_sqlite3 && cd $DIR_sqlite3 && \
    curl -Ls -o - "$URL_sqlite3" | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --enable-static \
        --disable-shared \
        --disable-dynamic-extensions && \
    make install -j$(nproc)

RUN mkdir -p $DIR_libssh2 && cd $DIR_libssh2 && \
    curl -Ls -o - "$URL_libssh2" | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --enable-static \
        --disable-shared \
        --disable-examples-build && \
    make install -j$(nproc)

## Build the master branch
RUN mkdir -p $DIR_aria2 && cd $DIR_aria2 && \
    git clone --depth 1 https://github.com/aria2/aria2.git .

## Build from release
# RUN mkdir -p $DIR_aria2 && cd $DIR_aria2 && \
#     curl -Ls -o - "https://github.com/aria2/aria2/releases/download/release-1.36.0/aria2-1.36.0.tar.gz" | tar zxvf - --strip-components=1

RUN mkdir -p $DIR_patch && cd $DIR_patch && \
    git clone --depth 1 https://github.com/Elypha/aria2-alter.git . && \
    cd $DIR_aria2 && \
    git apply $DIR_patch/aria2-patch/*.patch

RUN cd $DIR_aria2 && \
    export LD_LIBRARY_PATH="$DIR_prefix/lib" && \
    export PKG_CONFIG_PATH="$DIR_prefix/lib/pkgconfig" && \
    autoreconf -i && \
    ./configure \
        --prefix=$DIR_prefix \
        --with-libz \
        --with-libcares \
        --with-libexpat \
        --without-libxml2 \
        --without-libgcrypt \
        --with-openssl \
        --without-libnettle \
        --without-gnutls \
        --without-libgmp \
        --with-libssh2 \
        --with-sqlite3 \
        --without-jemalloc \
        --with-ca-bundle=$CURL_CA_BUNDLE \
        ARIA2_STATIC=yes \
        --disable-shared && \
    make -j$(nproc) && \
    $STRIP $DIR_aria2/src/aria2c && \
    mv $DIR_aria2/src/aria2c $DIR_root
