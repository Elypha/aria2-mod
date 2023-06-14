# Dockerfile to build aria2c binary on debian
# docker build -t aria2-windows-amd64 - < aria2c-windows-amd64.dockerfile
# docker run --name my_build aria2-windows-amd64
# docker cp my_build:/build/aria2c.exe .
# docker rm my_build
# docker rmi aria2-windows-amd64

FROM debian:12

LABEL MAINTAINER "Elypha"

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    make \
    binutils \
    autoconf \
    automake \
    autotools-dev \
    libtool \
    patch \
    ca-certificates \
    pkg-config \
    git \
    curl \
    wget \
    dpkg-dev \
    gcc-mingw-w64 \
    gcc-mingw-w64-x86-64 \
    g++-mingw-w64 \
    g++-mingw-w64-x86-64 \
    autopoint \
    libcppunit-dev \
    libxml2-dev \
    libgcrypt20-dev \
    lzip

ENV URL_zlib    "https://www.zlib.net/zlib-1.2.13.tar.gz"
ENV URL_expat   "https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.bz2"
ENV URL_c_ares  "https://c-ares.org/download/c-ares-1.19.1.tar.gz"
ENV URL_openssl "https://www.openssl.org/source/openssl-1.1.1u.tar.gz"
ENV URL_sqlite3 "https://www.sqlite.org/2023/sqlite-autoconf-3420000.tar.gz"
# libssh2-1.11.0 seems uncompatible with aria2 1.36.0
ENV URL_libssh2 "https://www.libssh2.org/download/libssh2-1.10.0.tar.gz"

ENV DIR_zlib      "/build/zlib"
ENV DIR_expat     "/build/expat"
ENV DIR_c_ares    "/build/c_ares"
ENV DIR_openssl   "/build/openssl"
ENV DIR_sqlite3   "/build/sqlite3"
ENV DIR_libssh2   "/build/libssh2"
ENV DIR_aria2     "/build/aria2"
ENV DIR_aria2_mod "/build/aria2-mod"

RUN mkdir -p $DIR_zlib    && wget -O - "$URL_zlib"    | tar -xz -C $DIR_zlib    --strip-components=1
RUN mkdir -p $DIR_expat   && wget -O - "$URL_expat"   | tar -xj -C $DIR_expat   --strip-components=1
RUN mkdir -p $DIR_c_ares  && wget -O - "$URL_c_ares"  | tar -xz -C $DIR_c_ares  --strip-components=1
RUN mkdir -p $DIR_openssl && wget -O - "$URL_openssl" | tar -xz -C $DIR_openssl --strip-components=1
RUN mkdir -p $DIR_sqlite3 && wget -O - "$URL_sqlite3" | tar -xz -C $DIR_sqlite3 --strip-components=1
RUN mkdir -p $DIR_libssh2 && wget -O - "$URL_libssh2" | tar -xz -C $DIR_libssh2 --strip-components=1

RUN mkdir -p $DIR_aria2 && git clone --depth 1 https://github.com/aria2/aria2.git $DIR_aria2
RUN mkdir -p $DIR_aria2_mod && git clone --depth 1 https://github.com/Elypha/aria2-mod.git $DIR_aria2_mod

ENV HOST   "x86_64-w64-mingw32"
ENV PREFIX "/usr/local/$HOST"

ENV STRIP           "$HOST-strip"
ENV LD_LIBRARY_PATH "$PREFIX/lib"
ENV PKG_CONFIG_PATH "$PREFIX/lib/pkgconfig"
ENV CURL_CA_BUNDLE  "/etc/ssl/certs/ca-certificates.crt"


RUN cd $DIR_zlib && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --static && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_expat && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --without-examples \
    --without-tests \
    --without-docbook && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_c_ares && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --disable-tests && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_openssl && \
    ./Configure \
    "mingw64" "no-shared" "no-asm" "no-tests" \
    --cross-compile-prefix=$HOST- \
    --prefix=$PREFIX && \
    make -j$(nproc) && \
    make install_sw

RUN cd $DIR_sqlite3 && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --disable-dynamic-extensions && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_libssh2 && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --enable-static \
    --disable-shared \
    --disable-examples-build && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_aria2 && \
    git apply $DIR_aria2_mod/aria2-patch/*.patch

RUN cd $DIR_aria2 && \
    autoreconf -i

RUN cd $DIR_aria2 && \
    ./configure \
    CPPFLAGS="-I$PREFIX/include" \
    LDFLAGS="-L$PREFIX/lib" \
    --host=$HOST \
    --with-cppunit-prefix=$PREFIX \
    --without-included-gettext \
    --disable-nls \
    --prefix=$PREFIX \
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
    ARIA2_STATIC=yes \
    --disable-shared

RUN cd $DIR_aria2 && \
    make -j$(nproc) && \
    $STRIP "src/aria2c.exe" && \
    mv "src/aria2c.exe" "/build/aria2c.exe"
