#! /bin/bash

set -e

WORKSPACE=/tmp/workspace
mkdir -p $WORKSPACE
mkdir -p /work/artifact

# brotli
cd $WORKSPACE
git clone https://github.com/google/brotli.git
cd brotli
mkdir build
cd build
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF ..
ninja
ninja install

# libev
cd $WORKSPACE
curl -sL http://dist.schmorp.de/libev/libev-4.33.tar.gz | tar x --gzip
cd libev-4.33
LDFLAGS="-static --static -no-pie -s" ./configure --prefix=/usr
make
make install

# nghttp3
cd $WORKSPACE
git clone https://github.com/ngtcp2/nghttp3.git
cd nghttp3
git submodule update --init --recursive
autoreconf -i
LDFLAGS="-static --static -no-pie -s" ./configure --prefix=/usr --enable-lib-only
make
make install

# ngtcp2
cd $WORKSPACE
git clone https://github.com/ngtcp2/ngtcp2.git
cd ngtcp2
git submodule update --init --recursive
autoreconf -i
LDFLAGS="-static --static -no-pie -s" ./configure --prefix=/usr --enable-lib-only --with-libbrotlienc --with-libbrotlidec
make
make install

# libevent
cd $WORKSPACE
git clone https://github.com/libevent/libevent.git
cd libevent
mkdir build
cd build
cmake -G Ninja -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=MinSizeRel -DBUILD_SHARED_LIBS=OFF ..
ninja
ninja install

# unbound
cd $WORKSPACE
curl -s https://www.nlnetlabs.nl/downloads/unbound/unbound-1.24.0.tar.gz | tar x --gzip
cd unbound-1.24.0
LDFLAGS="-levent_pthreads -levent_openssl -levent_extra -levent_core -levent -lngtcp2 -lngtcp2_crypto_ossl -lnghttp3 -lnghttp2 -lexpat -lssl -lcrypto -lc" \
 ./configure --with-libevent=/usr --with-libexpat=/usr --with-ssl=/usr --enable-dnscrypt --enable-ipset --enable-dnstap --enable-dnscrypt --with-libmnl --enable-subnet \
 --prefix=/usr/local/unboundmm --with-libnghttp2=/usr --with-libngtcp2=/usr --enable-fully-static
 sed -i 's@LDFLAGS=@LDFLAGS=-static --static -no-pie -s @g'  ./Makefile
 make
 make install

cd /usr/local
tar vcJf ./unboundmm.tar.xz unboundmm

mv ./unboundmm.tar.xz /work/artifact/
