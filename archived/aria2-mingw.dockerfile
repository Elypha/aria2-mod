# Dockerfile to build aria2 Windows binary using debian mingw-w64 cross compiler chain.
#
# $ docker build -t aria2-mingw-compile - < aria2-mingw.dockerfile
#
# After build, binary is at '/build/aria2c.exe'.
# You may extract the binary using following commands:
#
# $ id=$(docker create aria2-mingw-compile) && docker cp $id:/build/aria2c.exe . && docker rm -v $id
# (optional) $ docker rmi aria2-mingw-compile
# (optional) $ docker image prune
# (optional) $ docker system prune

FROM debian:10

LABEL MAINTAINER="Elypha Rin"

ENV DEBIAN_FRONTEND=noninteractive


## It would be better to use nearest debian archive mirror for faster downloads.
RUN echo "deb http://mirrors.aliyun.com/debian/ buster main contrib non-free" > /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian/ buster-backports main contrib non-free" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.aliyun.com/debian-security buster/updates main contrib non-free" >> /etc/apt/sources.list

## You may also use your preferred DNS server.
RUN echo "nameserver 192.168.1.5" > /etc/resolv.conf

RUN apt-get update && \
    apt-get install -y \
        git wget build-essential ca-certificates pkg-config lzip binutils dpkg-dev \
        autoconf automake autotools-dev autopoint libtool \
        libxml2-dev libcppunit-dev libgcrypt20-dev \
        gcc-mingw-w64 g++-mingw-w64


# Use 'x86_64-w64-mingw32' to build 64-bit binary or 'i686-w64-mingw32' to build 32-bit.
ENV HOST x86_64-w64-mingw32

ENV CC      "$HOST-gcc"
ENV CXX     "$HOST-g++"
ENV AR      "$HOST-ar"
ENV LD      "$HOST-ld"
ENV RANLIB  "$HOST-ranlib"
ENV STRIP   "$HOST-strip"


ENV DL_libgmp    "https://gmplib.org/download/gmp/gmp-6.2.1.tar.xz"
ENV DL_zlib      "https://www.zlib.net/zlib-1.2.11.tar.gz"
ENV DL_libexpat  "https://github.com/libexpat/libexpat/releases/download/R_2_2_10/expat-2.2.10.tar.gz"
ENV DL_c_ares    "https://c-ares.haxx.se/download/c-ares-1.17.1.tar.gz"
ENV DL_sqlite3   "https://www.sqlite.org/2021/sqlite-autoconf-3340100.tar.gz"
ENV DL_libssh2   "https://www.libssh2.org/download/libssh2-1.9.0.tar.gz"


ENV DIR_base      "/build"

ENV DIR_libgmp    "$DIR_base/src/libgmp"
ENV DIR_zlib      "$DIR_base/src/zlib"
ENV DIR_libexpat  "$DIR_base/src/libexpat"
ENV DIR_c_ares    "$DIR_base/src/c_ares"
ENV DIR_sqlite3   "$DIR_base/src/sqlite3"
ENV DIR_libssh2   "$DIR_base/src/libssh2"

ENV DIR_aria2     "$DIR_base/src/aria2"
ENV DIR_patch     "$DIR_base/src/patch"


ENV http_proxy    "http://192.168.1.5:10080"
ENV https_proxy   "http://192.168.1.5:10080"


RUN mkdir -p $DIR_libgmp && cd $DIR_libgmp && \
    wget $DL_libgmp -O - | tar Jxf - --strip-components=1 && \
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --enable-static \
        --disable-shared \
        --disable-cxx \
        --enable-fat \
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
        --enable-static \
        --disable-shared && \
    make install -j$(nproc)

RUN mkdir -p $DIR_c_ares && cd $DIR_c_ares && \
    wget $DL_c_ares -O - | tar zxf - --strip-components=1 && \
    # fix 1.17.1
    wget https://raw.githubusercontent.com/myfreeer/aria2-build-msys2/master/c-ares-1.17.1-fix-autotools-static-library.patch && \
    git apply c-ares-1.17.1-fix-autotools-static-library.patch && \
    autoreconf -fi && \
    # fix done
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --enable-static \
        --disable-shared \
        --without-random \
        --disable-tests && \
    make install -j$(nproc)

RUN mkdir -p $DIR_sqlite3 && cd $DIR_sqlite3 && \
    wget $DL_sqlite3 -O - | tar zxf - --strip-components=1 && \
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --enable-static \
        --disable-shared && \
    make install -j$(nproc)

RUN mkdir -p $DIR_libssh2 && cd $DIR_libssh2 && \
    wget $DL_libssh2 -O - | tar zxf - --strip-components=1 && \
    # fix 1.9.0
    wget https://raw.githubusercontent.com/myfreeer/aria2-build-msys2/master/libssh2-1.9.0-wincng-multiple-definition.patch && \
    git apply libssh2-1.9.0-wincng-multiple-definition.patch && \
    # fix done
    ./configure \
        --prefix=/usr/local/$HOST \
        --host=$HOST \
        --enable-static \
        --disable-shared \
        --with-crypto=wincng \
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
    # make check && \
    $HOST-strip $DIR_aria2/src/aria2c.exe && \
    mv $DIR_aria2/src/aria2c.exe /build/aria2c.exe && \
    echo "All Done!"
