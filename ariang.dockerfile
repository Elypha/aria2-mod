# Dockerfile to build aria2 binary with debian
#
# docker build -t ariang-build - < ariang.dockerfile
#
# After build, binary is at '/build/ariang'
# You may extract the binary using following commands:
#
# id=$(docker create ariang-build)
# docker cp $id:/build/aria2c .
# docker rm -v $id
# docker image prune

FROM debian:11

LABEL MAINTAINER "Elypha"

ENV DEBIAN_FRONTEND "noninteractive"

ENV URL_nodejs="https://nodejs.org/dist/v19.0.0/node-v19.0.0-linux-x64.tar.xz"

ENV DIR_root    "/build"
ENV DIR_nodejs  "$DIR_root/nodejs"
ENV DIR_ariang  "$DIR_root/ariang"
ENV DIR_patch   "$DIR_root/patch"


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates

RUN mkdir -p $DIR_nodejs && cd $DIR_nodejs && \
    curl -Ls -o - "$URL_nodejs" | tar Jxf - --strip-components=1


# build master branch
RUN mkdir -p $DIR_ariang && cd $DIR_ariang && \
    git clone https://github.com/mayswind/AriaNg-Native.git .

RUN mkdir -p $DIR_patch && cd $DIR_patch && \
    git clone https://github.com/Elypha/aria2-alter.git . && \
    cd $DIR_ariang && \
    git apply $DIR_patch/ariang-native-patch/*.patch

RUN export PATH=$DIR_nodejs/bin:$PATH && \
    cd $DIR_ariang && \
    npm install && \
    npm run publish:win && \
    npm run publish:osx
