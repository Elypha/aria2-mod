#!/bin/bash
set -e

apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    libxml2-dev \
    libcppunit-dev \
    autoconf \
    automake \
    autotools-dev \
    autopoint \
    libtool \
    pkg-config

PREFIX=/usr/local

export CC="gcc"
export CXX="g++"
export AR="ar"
export LD="ld"
export RANLIB="ranlib"
export STRIP="strip"

export LD_LIBRARY_PATH="$PREFIX/lib"
export PKG_CONFIG="/usr/bin/pkg-config"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$PREFIX/lib/pkgconfig"
export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"

URL_zlib="https://www.zlib.net/zlib-1.2.13.tar.gz"
URL_expat="https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.bz2"
URL_c_ares="https://c-ares.org/download/c-ares-1.19.1.tar.gz"
URL_openssl="https://www.openssl.org/source/openssl-1.1.1u.tar.gz"
URL_sqlite3="https://www.sqlite.org/2023/sqlite-autoconf-3420000.tar.gz"
URL_libssh2="https://www.libssh2.org/download/libssh2-1.11.0.tar.gz"

mkdir -p /build/zlib && wget -O - "$URL_zlib" | tar -xz -C /build/zlib --strip-components=1
mkdir -p /build/expat && wget -O - "$URL_expat" | tar -xj -C /build/expat --strip-components=1
mkdir -p /build/c_ares && wget -O - "$URL_c_ares" | tar -xz -C /build/c_ares --strip-components=1
mkdir -p /build/openssl && wget -O - "$URL_openssl" | tar -xz -C /build/openssl --strip-components=1
mkdir -p /build/sqlite3 && wget -O - "$URL_sqlite3" | tar -xz -C /build/sqlite3 --strip-components=1
mkdir -p /build/libssh2 && wget -O - "$URL_libssh2" | tar -xz -C /build/libssh2 --strip-components=1

mkdir -p /build/aria2 && git clone --depth 1 https://github.com/aria2/aria2.git /build/aria2
mkdir -p /build/aria2-mod && git clone --depth 1 https://github.com/Elypha/aria2-mod.git /build/aria2-mod

# zlib
cd /build/zlib
./configure \
    --prefix=$PREFIX \
    --static
make -j$(nproc)
make install

# expat
cd /build/expat
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared \
    --without-examples \
    --without-tests \
    --without-docbook
make -j$(nproc)
make install

# c-ares
cd /build/c_ares
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared
make -j$(nproc)
make install

# openssl
cd /build/openssl
./Configure linux-x86_64 no-shared no-asm \
    --prefix=$PREFIX
make -j$(nproc)
make install_sw

# sqlite3
cd /build/sqlite3
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared
make -j$(nproc)
make install

# libssh2
cd /build/libssh2
./configure \
    --prefix=$PREFIX \
    --enable-static \
    --disable-shared \
    --disable-examples-build
make -j$(nproc)
make install

# build aria2
cd /build/aria2
git apply /build/aria2-mod/aria2-patch/*.patch

autoreconf -i
./configure \
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
    --with-ca-bundle=$CURL_CA_BUNDLE \
    ARIA2_STATIC=yes \
    --disable-shared
make -j$(nproc)
$STRIP $DIR_aria2/src/aria2c
mv $DIR_aria2/src/aria2c $DIR_root
