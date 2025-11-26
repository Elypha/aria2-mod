# build     : docker build -f <example.dockerfile> --output type=local,dest=. .
# clean up  : docker builder prune --force

FROM debian:13 AS builder

LABEL MAINTAINER="Elypha"


# common dependencies
# --------------------------------
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    wget \
    ca-certificates \
    7zip

ENV URL_libssh2="https://github.com/libssh2/libssh2/releases/download/libssh2-1.11.1/libssh2-1.11.1.tar.gz" \
    URL_c_ares="https://github.com/c-ares/c-ares/releases/download/v1.34.5/c-ares-1.34.5.tar.gz" \
    URL_zlib="https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz" \
    URL_sqlite3="https://www.sqlite.org/2025/sqlite-autoconf-3500400.tar.gz" \
    URL_openssl="https://github.com/openssl/openssl/releases/download/OpenSSL_1_1_1w/openssl-1.1.1w.tar.gz" \
    URL_expat="https://github.com/libexpat/libexpat/releases/download/R_2_7_1/expat-2.7.1.tar.bz2"

ENV DIR_libssh2="/build/libssh2" \
    DIR_c_ares="/build/c_ares" \
    DIR_zlib="/build/zlib" \
    DIR_sqlite3="/build/sqlite3" \
    DIR_openssl="/build/openssl" \
    DIR_expat="/build/expat"

ENV DIR_aria2="/build/aria2" \
    DIR_patch="/build/patch"

RUN mkdir -p $DIR_libssh2 && wget -O - "$URL_libssh2" | tar -xz -C $DIR_libssh2 --strip-components=1
RUN mkdir -p $DIR_c_ares  && wget -O - "$URL_c_ares"  | tar -xz -C $DIR_c_ares  --strip-components=1
RUN mkdir -p $DIR_zlib    && wget -O - "$URL_zlib"    | tar -xz -C $DIR_zlib    --strip-components=1
RUN mkdir -p $DIR_sqlite3 && wget -O - "$URL_sqlite3" | tar -xz -C $DIR_sqlite3 --strip-components=1
RUN mkdir -p $DIR_openssl && wget -O - "$URL_openssl" | tar -xz -C $DIR_openssl --strip-components=1
RUN mkdir -p $DIR_expat   && wget -O - "$URL_expat"   | tar -xj -C $DIR_expat   --strip-components=1

RUN mkdir -p $DIR_aria2     && git clone --depth 1 https://github.com/aria2/aria2.git $DIR_aria2


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

ENV PREFIX="/usr/local"

ENV CC="gcc" \
    CXX="g++" \
    AR="ar" \
    LD="ld" \
    RANLIB="ranlib" \
    STRIP="strip"

ENV LD_LIBRARY_PATH="$PREFIX/lib" \
    PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig"

ENV CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"


# build dependencies
# --------------------------------
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
    --enable-static && \
    make -j$(nproc) && \
    make install



# build aria2
# --------------------------------
WORKDIR $DIR_patch

COPY aria2-patch/ $DIR_patch


WORKDIR $DIR_aria2

RUN git apply $DIR_patch/*.patch

RUN autoreconf -i
RUN ./configure \
    --prefix=$PREFIX \
    # disable i18n
    --without-included-gettext \
    --disable-nls \
    # use expat instead of libxml2 to mitigate `iconv.h` related issues
    # it's faster and better-supported than libxml2
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

RUN make -j$(nproc)
RUN $STRIP "src/aria2c"


WORKDIR /dist

RUN mv "$DIR_aria2/src/aria2c" .

FROM scratch AS extractor

COPY --from=builder /dist/ /
