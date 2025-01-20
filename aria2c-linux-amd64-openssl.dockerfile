# build
# $ docker build -t build_image - < aria2c-linux-amd64-openssl.dockerfile
# extract
# $ docker run --name build_image build_image
# $ docker cp build_image:/build/aria2c .
# $ docker rm build_image
# $ docker rmi build_image
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

ENV URL_libssh2  "https://www.libssh2.org/download/libssh2-1.11.1.tar.gz"
ENV URL_c_ares   "https://github.com/c-ares/c-ares/releases/download/v1.34.4/c-ares-1.34.4.tar.gz"
ENV URL_zlib     "https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz"
ENV URL_sqlite3  "https://www.sqlite.org/2023/sqlite-autoconf-3430100.tar.gz"
ENV URL_openssl  "https://www.openssl.org/source/openssl-1.1.1w.tar.gz"
ENV URL_expat    "https://github.com/libexpat/libexpat/releases/download/R_2_6_4/expat-2.6.4.tar.bz2"

ENV DIR_libssh2  "/build/libssh2"
ENV DIR_c_ares   "/build/c_ares"
ENV DIR_zlib     "/build/zlib"
ENV DIR_sqlite3  "/build/sqlite3"
ENV DIR_openssl  "/build/openssl"
ENV DIR_expat    "/build/expat"

RUN mkdir -p $DIR_libssh2 && wget -O - "$URL_libssh2" | tar -xz -C $DIR_libssh2 --strip-components=1
RUN mkdir -p $DIR_c_ares  && wget -O - "$URL_c_ares"  | tar -xz -C $DIR_c_ares  --strip-components=1
RUN mkdir -p $DIR_zlib    && wget -O - "$URL_zlib"    | tar -xz -C $DIR_zlib    --strip-components=1
RUN mkdir -p $DIR_sqlite3 && wget -O - "$URL_sqlite3" | tar -xz -C $DIR_sqlite3 --strip-components=1
RUN mkdir -p $DIR_openssl && wget -O - "$URL_openssl" | tar -xz -C $DIR_openssl --strip-components=1
RUN mkdir -p $DIR_expat   && wget -O - "$URL_expat"   | tar -xj -C $DIR_expat   --strip-components=1

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
    liblzma-dev

ENV PREFIX "/usr/local"

ENV CC      "gcc"
ENV CXX     "g++"
ENV AR      "ar"
ENV LD      "ld"
ENV RANLIB  "ranlib"

ENV STRIP            "strip"
ENV LD_LIBRARY_PATH  "$PREFIX/lib"
ENV PKG_CONFIG_PATH  "$PREFIX/lib/pkgconfig"
ENV CURL_CA_BUNDLE   "/etc/ssl/certs/ca-certificates.crt"



# build dependencies
# --------------------------------

# build c_ares first since recv, recvfrom can take ages
RUN cd $DIR_c_ares && \
    ./configure \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    --disable-tests && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_expat && \
    ./configure \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    --without-examples \
    --without-tests \
    --without-docbook && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_zlib && \
    ./configure \
    --prefix=$PREFIX \
    --static && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_openssl && \
    ./Configure \
    "linux-x86_64" "no-tests" \
    --prefix=$PREFIX && \
    make -j$(nproc) && \
    make install_sw

RUN cd $DIR_libssh2 && \
    autoreconf -fi && \
    ./configure \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    --disable-examples-build && \
    make -j$(nproc) && \
    make install

RUN cd $DIR_sqlite3 && \
    ./configure \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    --disable-dynamic-extensions && \
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
    # configure options
    --prefix=$PREFIX \
    # disable i18n
    --without-included-gettext \
    --disable-nls \
    # use expat instead of libxml2 to avoid `iconv.h` related error
    --with-libexpat \
    --without-libxml2 \
    # use openssl instead of gnutls
    --without-gnutls \
    --without-libnettle \
    --without-libgmp \
    --without-libgcrypt \
    --with-openssl \
    --with-ca-bundle=$CURL_CA_BUNDLE \
    # other dependencies
    --with-libz \
    --with-libcares \
    --with-libssh2 \
    --with-sqlite3 \
    # --without-jemalloc \
    --disable-shared \
    ARIA2_STATIC=yes

RUN cd $DIR_aria2 && \
    make -j$(nproc) && \
    $STRIP "src/aria2c" && \
    mv "src/aria2c" "/build/aria2c"
