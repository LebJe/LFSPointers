ARG ARCH=
FROM ${ARCH}ubuntu:focal

LABEL maintainer="LebJe"
LABEL Description="A Swift library and CLI that allows you to convert a Git repository of large files to Git LFS pointers."
LABEL org.opencontainers.image.source https://github.com/LebJe/LFSPointers

RUN apt update -q && apt install wget -yq && rm -rf /var/lib/apt/lists/*

COPY Scripts .

RUN ./installDeb.sh
