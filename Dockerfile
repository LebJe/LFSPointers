ARG ARCH=
FROM ${ARCH}ubuntu:focal

LABEL maintainer="LebJe"
LABEL Description="A command line tool and SPM package that allows you to convert a Git repository directory of large files to Git LFS pointers."
LABEL org.opencontainers.image.source https://github.com/LebJe/LFSPointers

RUN apt update -q && apt install wget -yq && rm -rf /var/lib/apt/lists/*

COPY Scripts .

RUN ./installDeb.sh
