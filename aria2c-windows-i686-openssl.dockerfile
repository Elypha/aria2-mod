# build
# $ docker build -t build_i - < aria2c-windows-x86_64-openssl.dockerfile
# extract
# $ docker run --name build_c build_i
# $ docker cp build_c:/build/aria2c.exe .
# $ docker rm build_c
# $ docker rmi build_i
# clean
# $ docker builder prune --force

FROM debian:12

LABEL MAINTAINER "Elypha"

ENV DEBIAN_FRONTEND noninteractive



# basic dependencies
# --------------------------------

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    p7zip-full

ENV URL_libssh2  "https://www.libssh2.org/download/libssh2-1.11.0.tar.gz"
ENV URL_c_ares   "https://c-ares.org/download/c-ares-1.19.1.tar.gz"
ENV URL_zlib     "https://www.zlib.net/zlib-1.3.tar.gz"
ENV URL_sqlite3  "https://www.sqlite.org/2023/sqlite-autoconf-3430100.tar.gz"
ENV URL_openssl  "https://www.openssl.org/source/openssl-1.1.1w.tar.gz"
ENV URL_expat    "https://github.com/libexpat/libexpat/releases/download/R_2_5_0/expat-2.5.0.tar.bz2"
ENV URL_gmp      "https://gmplib.org/download/gmp/gmp-6.3.0.tar.xz"

ENV DIR_libssh2  "/build/libssh2"
ENV DIR_c_ares   "/build/c_ares"
ENV DIR_zlib     "/build/zlib"
ENV DIR_sqlite3  "/build/sqlite3"
ENV DIR_openssl  "/build/openssl"
ENV DIR_expat    "/build/expat"
ENV DIR_gmp      "/build/gmp"

RUN mkdir -p $DIR_libssh2 && wget -O - "$URL_libssh2" | tar -xz -C $DIR_libssh2 --strip-components=1
RUN mkdir -p $DIR_c_ares  && wget -O - "$URL_c_ares"  | tar -xz -C $DIR_c_ares  --strip-components=1
RUN mkdir -p $DIR_zlib    && wget -O - "$URL_zlib"    | tar -xz -C $DIR_zlib    --strip-components=1
RUN mkdir -p $DIR_sqlite3 && wget -O - "$URL_sqlite3" | tar -xz -C $DIR_sqlite3 --strip-components=1
RUN mkdir -p $DIR_openssl && wget -O - "$URL_openssl" | tar -xz -C $DIR_openssl --strip-components=1
RUN mkdir -p $DIR_expat   && wget -O - "$URL_expat"   | tar -xj -C $DIR_expat   --strip-components=1
RUN mkdir -p $DIR_gmp     && wget -O - "$URL_gmp"     | tar -xJ -C $DIR_gmp     --strip-components=1

ENV DIR_aria2      "/build/aria2"
ENV DIR_aria2_mod  "/build/aria2-mod"
RUN mkdir -p $DIR_aria2     && git clone --depth 1 https://github.com/aria2/aria2.git $DIR_aria2
RUN mkdir -p $DIR_aria2_mod && git clone --depth 1 https://github.com/Elypha/aria2-mod.git $DIR_aria2_mod



# aria2 dependencies
# --------------------------------

RUN apt-get install -y --no-install-recommends \
    # deps: autoconf
    libxml2-dev \
    libcppunit-dev \
    autoconf \
    automake \
    autotools-dev \
    autopoint \
    libtool \
    # deps: aria2
    pkg-config \
    # libxml2-dev \
    liblzma-dev \
    # deps: cross compile
    gcc-mingw-w64 \
    gcc-mingw-w64-x86-64 \
    g++-mingw-w64 \
    g++-mingw-w64-x86-64

ENV HOST          "i686-w64-mingw32"
ENV OPENSSL_HOST  "mingw"
ENV PREFIX        "/usr/local/$HOST"

ENV STRIP            "$HOST-strip"
ENV LD_LIBRARY_PATH  "$PREFIX/lib"
ENV PKG_CONFIG_PATH  "$PREFIX/lib/pkgconfig"
ENV CURL_CA_BUNDLE   "/etc/ssl/certs/ca-certificates.crt"



# build dependencies
# --------------------------------

# build c_ares first since recv, recvfrom can take ages
RUN cd $DIR_c_ares && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --disable-tests && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_expat && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --without-examples \
    --without-tests \
    --without-docbook && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_zlib && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --static && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_openssl && \
    ./Configure \
    $OPENSSL_HOST "no-shared" "no-asm" "no-tests" \
    --prefix=$PREFIX \
    --cross-compile-prefix=$HOST- && \
    make -j$(nproc) && \
    make install_sw

RUN cd $DIR_libssh2 && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --disable-examples-build && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_sqlite3 && \
    CC="$HOST-gcc" CXX="$HOST-g++" AR="$HOST-ar" LD="$HOST-ld" RANLIB="$HOST-ranlib" \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --disable-dynamic-extensions && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_gmp && \
    ./configure \
    --prefix=$PREFIX \
    --host=$HOST \
    --disable-shared \
    --enable-static \
    --disable-cxx \
    --enable-fat \
    CFLAGS="-mtune=generic -O2 -g0" && \
    make -j$(nproc) && \
    make install



# build aria2
# --------------------------------

RUN cd $DIR_aria2 && \
    git apply $DIR_aria2_mod/aria2-patch/*.patch

RUN cd $DIR_aria2 && \
    autoreconf -i

RUN cd $DIR_aria2 && \
    ./configure \
    # cross compile
    CPPFLAGS="-I$PREFIX/include" \
    LDFLAGS="-L$PREFIX/lib" \
    --host=$HOST \
    --with-cppunit-prefix=$PREFIX \
    # configure options
    --prefix=$PREFIX \
    # disable i18n
    --without-included-gettext \
    --disable-nls \
    # use expat instead of libxml2 to avoid `iconv.h` related error
    --with-libexpat \
    --without-libxml2 \
    # use openssl instead of gnutls
    # for windows:
    # 1) use `openssl`
    #    - you need to provide the ca file manually in the config, e.g., `ca-certificate=/path/to/ca-bundle.crt`
    --without-wintls \
    --without-gnutls \
    --without-libnettle \
    --without-libgmp \
    --without-libgcrypt \
    --with-openssl \
    --with-ca-bundle=$CURL_CA_BUNDLE \
    #
    # 2) use `wintls`
    #    - `openssl` is no longer needed and the windows certificate store will be used
    #    - `libgmp` is required for BitTorrent (will use `libgmp + libnettle`, but `libnettle` is not required since wintls is used)
    # --with-wintls \
    # --without-gnutls \
    # --without-libnettle \
    # --with-libgmp \
    # --without-libgcrypt \
    # --without-openssl \
    #
    # other dependencies
    --with-libz \
    --with-libcares \
    --with-libssh2 \
    --with-sqlite3 \
    # static build
    --disable-shared \
    ARIA2_STATIC=yes

RUN cd $DIR_aria2 && \
    make -j$(nproc) && \
    $STRIP "src/aria2c.exe" && \
    mv "src/aria2c.exe" "/build/aria2c.exe"
