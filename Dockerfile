FROM alpine:latest

# https://mirrors.alpinelinux.org/
RUN sed -i 's@dl-cdn.alpinelinux.org@ftp.halifax.rwth-aachen.de@g' /etc/apk/repositories

RUN apk update
RUN apk upgrade

# required unbound 
RUN apk add --no-cache \
 gcc make linux-headers musl-dev zlib-dev zlib-static \
 python3-dev curl protobuf-c-dev nghttp2-dev nghttp2-static \
 libevent-dev libevent-static libmnl-dev libmnl-static \
 libsodium-dev libsodium-static expat-dev expat-static \
 openssl-libs-static openssl-dev bash \
 git libtool autoconf automake g++ cmake ninja jemalloc-dev jemalloc-static

ENV XZ_OPT=-e9
COPY build-static-unbound.sh build-static-unbound.sh
RUN chmod +x ./build-static-unbound.sh
RUN bash ./build-static-unbound.sh
