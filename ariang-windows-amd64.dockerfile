# Dockerfile to build aria2c binary on debian
# docker build -t ariang - < ariang.dockerfile
# docker run --name my_build ariang
# docker cp my_build:/build/aria2c.exe .
# docker rm my_build
# docker rmi aria2-windows-amd64

FROM debian:12

LABEL MAINTAINER "Elypha"

ENV DEBIAN_FRONTEND "noninteractive"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    curl \
    wget \
    ca-certificates

ENV URL_nodejs="https://nodejs.org/dist/v20.3.0/node-v20.3.0-linux-x64.tar.gz"

ENV DIR_nodejs    "/usr/local"
ENV DIR_ariang    "/build/ariang"
ENV DIR_aria2_mod "/build/aria2-mod"

RUN mkdir -p $DIR_nodejs && wget -O - "$URL_nodejs" | tar -xz -C $DIR_nodejs --strip-components=1

RUN mkdir -p $DIR_ariang    && git clone --depth 1 https://github.com/mayswind/AriaNg-Native.git $DIR_ariang
RUN mkdir -p $DIR_aria2_mod && git clone --depth 1 https://github.com/Elypha/aria2-mod.git $DIR_aria2_mod


RUN cd $DIR_ariang && \
    git apply $DIR_aria2_mod/ariang-native-patch/*.patch

RUN cd $DIR_ariang && \
    npm install

RUN cd $DIR_ariang && \
    npm run publish:win

# broken. RIP OSX
# RUN cd $DIR_ariang && \
#     npm run publish:osx
