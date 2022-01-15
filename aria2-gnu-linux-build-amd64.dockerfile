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

FROM debian:11

LABEL MAINTAINER="Elypha"

ENV DEBIAN_FRONTEND=noninteractive

ENV URL_zlib       "https://www.zlib.net/zlib-1.2.11.tar.gz"
ENV URL_expat      "https://github.com/libexpat/libexpat/releases/download/R_2_4_1/expat-2.4.1.tar.bz2"
ENV URL_c_ares     "https://c-ares.haxx.se/download/c-ares-1.17.2.tar.gz"
ENV URL_openssl    "https://www.openssl.org/source/openssl-1.1.1k.tar.gz"
ENV URL_sqlite3    "https://www.sqlite.org/2021/sqlite-autoconf-3360000.tar.gz"
ENV URL_libssh2    "https://www.libssh2.org/download/libssh2-1.9.0.tar.gz"

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


## Options for poor connection
# RUN echo "nameserver 223.5.5.5" > /etc/resolv.conf
# ENV http_proxy   "http://192.168.1.5:10080"
# ENV https_proxy  "http://192.168.1.5:10080"
# RUN echo "deb http://mirrors.aliyun.com/debian/ buster main contrib non-free" > /etc/apt/sources.list && \
#     echo "deb http://mirrors.aliyun.com/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb http://mirrors.aliyun.com/debian/ buster-backports main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb http://mirrors.aliyun.com/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list

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
    wget $URL_zlib -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --static && \
    make install -j$(nproc)

RUN mkdir -p $DIR_expat && cd $DIR_expat && \
    wget $URL_expat -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --enable-static \
        --disable-shared \
        --without-examples \
        --without-tests \
        --without-docbook && \
    make install -j$(nproc)

RUN mkdir -p $DIR_c_ares && cd $DIR_c_ares && \
    wget $URL_c_ares -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --enable-static \
        --disable-shared \
        --disable-tests && \
    make install -j$(nproc)

RUN mkdir -p $DIR_openssl && cd $DIR_openssl && \
    wget $URL_openssl -O - | tar zxf - --strip-components=1 && \
    ./Configure \
        --prefix=$DIR_prefix \
        "linux-x86_64" \
        no-tests && \
    # make install_sw  # use single thread to avoid potential crash
    make install_sw -j$(nproc)

RUN mkdir -p $DIR_sqlite3 && cd $DIR_sqlite3 && \
    wget $URL_sqlite3 -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --enable-static \
        --disable-shared \
        --disable-dynamic-extensions && \
    make install -j$(nproc)

RUN mkdir -p $DIR_libssh2 && cd $DIR_libssh2 && \
    wget $URL_libssh2 -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_prefix \
        --enable-static \
        --disable-shared \
        --disable-examples-build && \
    make install -j$(nproc)

## Build from release
# RUN mkdir -p $DIR_patch && cd $DIR_patch && \
#     git clone https://github.com/Elypha/aria2-alter.git . && \
#     mkdir -p $DIR_aria2 && cd $DIR_aria2 && \
#     wget https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.gz -O - | tar zxf - --strip-components=1 && \
#     git apply $DIR_patch/aria2-patch/*.patch && \
#     autoreconf -fi && \
#     ./configure \
#         --prefix="/usr/loacl" \
#         --with-libz \
#         --with-libcares \
#         --with-libexpat \
#         --without-libxml2 \
#         --without-libgcrypt \
#         --with-openssl \
#         --without-libnettle \
#         --without-gnutls \
#         --without-libgmp \
#         --with-libssh2 \
#         --with-sqlite3 \
#         --without-jemalloc \
#         --with-ca-bundle=$CURL_CA_BUNDLE \
#         ARIA2_STATIC=yes \
#         --disable-shared && \
#     make -j$(nproc) && \
#     # make check && \
#     $STRIP $DIR_aria2/src/aria2c && \
#     mv $DIR_aria2/src/aria2c $DIR_root && \
#     echo "All Done!"

## Build the master branch
RUN mkdir -p $DIR_patch && cd $DIR_patch && \
    git clone https://github.com/Elypha/aria2-alter.git . && \
    mkdir -p $DIR_aria2 && cd $DIR_aria2 && \
    git clone https://github.com/aria2/aria2.git . && \
    git apply $DIR_patch/aria2-patch/*.patch && \
    autoreconf -fi && \
    ./configure \
        --prefix="/usr/loacl" \
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
    # make check && \
    $STRIP $DIR_aria2/src/aria2c && \
    mv $DIR_aria2/src/aria2c $DIR_root && \
    echo "All Done!"
