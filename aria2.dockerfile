# Dockerfile to build aria2 binary using debian buster
#
# $ docker build -t aria2-compile - < Dockerfile.mingw
#
# After build, binary is at /build/aria2c
# You may extract the binary using following commands:
#
# $ id=$(docker create aria2-compile)
# $ docker cp $id:/build/aria2c .
# $ docker rm -v $id
# $ docker image prune

FROM debian:10

LABEL MAINTAINER="Elypha Rin"

ENV DEBIAN_FRONTEND=noninteractive

ENV DL_zlib       "https://www.zlib.net/zlib-1.2.11.tar.gz"
ENV DL_libexpat   "https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.gz"
ENV DL_c_ares     "https://c-ares.haxx.se/download/c-ares-1.16.1.tar.gz"
ENV DL_openssl    "https://www.openssl.org/source/openssl-1.1.1g.tar.gz"
ENV DL_sqlite3    "https://www.sqlite.org/2020/sqlite-autoconf-3330000.tar.gz"
ENV DL_libssh2    "https://www.libssh2.org/download/libssh2-1.9.0.tar.gz"

ENV DIR_base      "/build"
ENV DIR_zlib      "$DIR_base/src/zlib"
ENV DIR_libexpat  "$DIR_base/src/libexpat"
ENV DIR_c_ares    "$DIR_base/src/c_ares"
ENV DIR_openssl   "$DIR_base/src/openssl"
ENV DIR_sqlite3   "$DIR_base/src/sqlite3"
ENV DIR_libssh2   "$DIR_base/src/libssh2"
ENV DIR_aria2     "$DIR_base/src/aria2"
ENV DIR_patch     "$DIR_base/src/patch"
ENV DIR_libs      "$DIR_base/libs"
ENV DIR_build     "$DIR_base/build"

ENV CC      "gcc"
ENV CXX     "g++"
ENV AR      "ar"
ENV LD      "ld"
ENV RANLIB  "ranlib"
ENV STRIP   "strip"

ENV LD_LIBRARY_PATH  "$DIR_libs/lib"

## You may use proxy to help download
# ENV http_proxy   "http://127.0.0.1:1080"
# ENV https_proxy  "http://127.0.0.1:1080"

## It would be better to use nearest debian archive mirror for faster downloads.
# RUN echo "deb http://mirrors.aliyun.com/debian/ buster main contrib non-free" > /etc/apt/sources.list && \
#     echo "deb http://mirrors.aliyun.com/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb http://mirrors.aliyun.com/debian/ buster-backports main contrib non-free" >> /etc/apt/sources.list && \
#     echo "deb http://mirrors.aliyun.com/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list

## You may also use your preferred DNS server.
# RUN echo "nameserver 223.5.5.5" > /etc/resolv.conf

RUN apt-get update && \
    apt-get install -y \
        git wget build-essential ca-certificates pkg-config \
        libxml2-dev libcppunit-dev autoconf automake autotools-dev autopoint libtool

RUN mkdir -p $DIR_zlib && cd $DIR_zlib && \
    wget $DL_zlib -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_libs \
        --static && \
    make install -j$(nproc)

RUN mkdir -p $DIR_libexpat && cd $DIR_libexpat && \
    wget $DL_libexpat -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_libs \
        --enable-shared \
        --enable-static && \
    make install -j$(nproc)

RUN mkdir -p $DIR_c_ares && cd $DIR_c_ares && \
    wget $DL_c_ares -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_libs \
        --disable-shared \
        --enable-static && \
    make install -j$(nproc)

RUN mkdir -p $DIR_openssl && cd $DIR_openssl && \
    wget $DL_openssl -O - | tar zxf - --strip-components=1 && \
    ./Configure \
        linux-elf no-asm shared \
        --prefix=$DIR_libs \
        --openssldir=ssl && \
    # make install -j$(nproc)
    make install

RUN mkdir -p $DIR_sqlite3 && cd $DIR_sqlite3 && \
    wget $DL_sqlite3 -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_libs \
        --disable-shared \
        --enable-static && \
    make install -j$(nproc)

RUN mkdir -p $DIR_libssh2 && cd $DIR_libssh2 && \
    wget $DL_libssh2 -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=$DIR_libs \
        --disable-shared \
        --enable-static \
        CPPFLAGS="-I/$DIR_libs/include" \
        LDFLAGS="-L/$DIR_libs/lib" && \
    make install -j$(nproc)

## Build from release
RUN mkdir -p $DIR_aria2 && cd $DIR_aria2 && \
    wget https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.gz -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix="/usr/loacl" \
        --without-gnutls \
        --without-libnettle \
        --without-libgmp \
        --without-libxml2 \
        --without-libgcrypt \
        --with-libssh2 \
        --with-libcares \
        --with-libz \
        --with-sqlite3 \
        --with-openssl \
        --with-libexpat \
        --with-ca-bundle='/etc/ssl/certs/ca-certificates.crt' \
        --enable-shared=no \
        ARIA2_STATIC=yes \
        PKG_CONFIG_PATH="$DIR_libs/lib/pkgconfig" && \
    make -j$(nproc) && \
    # make check && \
    strip $DIR_aria2/src/aria2c && \
    mv $DIR_aria2/src/aria2c $DIR_base && \
    echo "All Done!"

## Build the master branch
# RUN mkdir -p $DIR_aria2 && cd $DIR_aria2 && \
#     git clone https://github.com/aria2/aria2.git . && \
#     autoreconf -i && \
#     ./configure \
#         --prefix="/usr/loacl" \
#         --without-gnutls \
#         --without-libnettle \
#         --without-libgmp \
#         --without-libxml2 \
#         --without-libgcrypt \
#         --with-libssh2 \
#         --with-libcares \
#         --with-libz \
#         --with-sqlite3 \
#         --with-openssl \
#         --with-libexpat \
#         --with-ca-bundle='/etc/ssl/certs/ca-certificates.crt' \
#         --enable-shared=no \
#         ARIA2_STATIC=yes \
#         PKG_CONFIG_PATH="$DIR_libs/lib/pkgconfig" && \
#     make -j$(nproc) && \
#     # make check && \
#     strip $DIR_aria2/src/aria2c && \
#     mv $DIR_aria2/src/aria2c $DIR_base && \
#     echo "All Done!"
