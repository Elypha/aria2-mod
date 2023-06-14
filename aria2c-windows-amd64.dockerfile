# Dockerfile to build aria2c binary on debian

FROM debian:12

LABEL MAINTAINER "Elypha"

ENV DEBIAN_FRONTEND noninteractive

ENV SCRIPT_URL "https://raw.githubusercontent.com/Elypha/aria2-mod/master/aria2c-windows-amd64.sh"

RUN curl -sSL $SCRIPT_URL | bash
