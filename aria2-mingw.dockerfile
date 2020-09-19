# Dockerfile to build aria2 Windows binary using ubuntu mingw-w64 cross compiler chain.
#
# $ docker build -t aria2-mingw-compile - < aria2-mingw.dockerfile
#
# After build, binary is at '/aria2/src/aria2c.exe'.
# You may extract the binary using following commands:
#
# $ id=$(docker create aria2-mingw-compile)
# $ docker cp $id:/aria2/src/aria2c.exe .
# $ docker rm -v $id
# $ docker image prune

FROM ubuntu:20.04

LABEL MAINTAINER="Elypha Rin"

# Use 'x86_64-w64-mingw32' to build 64-bit binary or 'i686-w64-mingw32' to build 32-bit.
ENV HOST x86_64-w64-mingw32

ENV DEBIAN_FRONTEND=noninteractive

ENV DL_libgmp     "https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz"
ENV DL_zlib       "https://www.zlib.net/zlib-1.2.11.tar.gz"
ENV DL_libexpat   "https://github.com/libexpat/libexpat/releases/download/R_2_2_9/expat-2.2.9.tar.gz"
ENV DL_c_ares     "https://c-ares.haxx.se/download/c-ares-1.16.1.tar.gz"
ENV DL_sqlite3    "https://www.sqlite.org/2020/sqlite-autoconf-3330000.tar.gz"
ENV DL_libssh2    "https://www.libssh2.org/download/libssh2-1.9.0.tar.gz"

ENV DIR_base      "/build"
ENV DIR_libgmp   "$DIR_base/src/libgmp"
ENV DIR_zlib      "$DIR_base/src/zlib"
ENV DIR_libexpat  "$DIR_base/src/libexpat"
ENV DIR_c_ares    "$DIR_base/src/c_ares"
ENV DIR_sqlite3   "$DIR_base/src/sqlite3"
ENV DIR_libssh2   "$DIR_base/src/libssh2"
ENV DIR_aria2     "$DIR_base/src/aria2"
ENV DIR_patch     "$DIR_base/src/patch"
ENV DIR_build     "$DIR_base/build"

ENV CC      "$HOST-gcc"
ENV CXX     "$HOST-g++"
ENV AR      "$HOST-ar"
ENV LD      "$HOST-ld"
ENV RANLIB  "$HOST-ranlib"
ENV STRIP   "$HOST-strip"

## You may use proxy to help download
# ENV http_proxy   "http://127.0.0.1:1080"
# ENV https_proxy  "http://127.0.0.1:1080"

## It would be better to use nearest ubuntu archive mirror for faster downloads.
# RUN echo "deb http://archive.ubuntu.com/ubuntu/ focal main restricted universe multiverse" > /etc/apt/sources.list && \
#     echo "deb http://archive.ubuntu.com/ubuntu/ focal-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
#     echo "deb http://archive.ubuntu.com/ubuntu/ focal-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
#     echo "deb http://security.ubuntu.com/ubuntu/ focal-security main restricted universe multiverse" >> /etc/apt/sources.list

## You may also use your preferred DNS server.
# RUN echo "nameserver 223.5.5.5" > /etc/resolv.conf

RUN apt-get update && \
    apt-get install -y \
        git wget build-essential ca-certificates pkg-config \
        libxml2-dev libcppunit-dev autoconf automake autotools-dev autopoint libtool libgcrypt20-dev \
        binutils dpkg-dev gcc-mingw-w64 g++-mingw-w64 lzip

RUN mkdir -p $DIR_libgmp && cd $DIR_libgmp && \
    wget $DL_libgmp -O - | tar Jxf - --strip-components=1 && \
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --disable-cxx \
        --enable-fat \
        --disable-shared \
        --enable-static \
        CFLAGS="-mtune=generic -O2 -g0" && \
    make install -j$(nproc)

RUN mkdir -p $DIR_zlib && cd $DIR_zlib && \
    wget $DL_zlib -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=/usr/local/$HOST \
        --libdir=/usr/local/$HOST/lib \
        --includedir=/usr/local/$HOST/include \
        --static && \
    make install -j$(nproc)

RUN mkdir -p $DIR_libexpat && cd $DIR_libexpat && \
    wget $DL_libexpat -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
        --disable-shared \
        --enable-static && \
    make install -j$(nproc)

RUN mkdir -p $DIR_c_ares && cd $DIR_c_ares && \
    wget $DL_c_ares -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
        --without-random \
        --disable-shared \
        --enable-static \
        LIBS="-lws2_32" && \
    make install -j$(nproc)

RUN mkdir -p $DIR_sqlite3 && cd $DIR_sqlite3 && \
    wget $DL_sqlite3 -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
        --disable-shared \
        --enable-static && \
    make install -j$(nproc)

RUN mkdir -p $DIR_libssh2 && cd $DIR_libssh2 && \
    wget $DL_libssh2 -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --disable-shared \
        --enable-static \
        --build=`dpkg-architecture -qDEB_BUILD_GNU_TYPE` \
        LIBS="-lws2_32" && \
    make install -j$(nproc)

RUN mkdir -p $DIR_aria2 && cd $DIR_aria2 && \
    wget https://github.com/aria2/aria2/releases/download/release-1.35.0/aria2-1.35.0.tar.gz -O - | tar zxf - --strip-components=1 && \
    git clone https://github.com/Elypha/aria2-alter.git $DIR_patch && \
    git apply $DIR_patch/aria2-patch/*.patch && \
    ./configure \
        --host=$HOST \
        --prefix=/usr/local/$HOST \
        --disable-nls \
        --without-included-gettext \
        --without-gnutls \
        --without-openssl \
        --without-libxml2 \
        --without-libgcrypt \
        --without-libnettle \
        --with-libcares \
        --with-sqlite3 \
        --with-libexpat \
        --with-libz \
        --with-libgmp \
        --with-libssh2 \
        --with-cppunit-prefix=/usr/local/$HOST \
        ARIA2_STATIC=yes \
        CPPFLAGS="-I/usr/local/$HOST/include" \
        LDFLAGS="-L/usr/local/$HOST/lib" \
        PKG_CONFIG="/usr/bin/pkg-config" \
        PKG_CONFIG_PATH="/usr/local/$HOST/lib/pkgconfig" && \
    make -j$(nproc) && \
    make check && \
    strip $DIR_aria2/src/aria2c.exe && \
    mv $DIR_aria2/src/aria2c.exe $DIR_build && \
    echo "All Done!"

