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

# unbound
cd $WORKSPACE
curl -s https://www.nlnetlabs.nl/downloads/unbound/unbound-1.24.0.tar.gz | tar x --gzip
cd unbound-1.24.0
LDFLAGS="-static --static -no-pie -s" \
 ./configure --with-libevent --with-libexpat=/usr --with-ssl --enable-dnscrypt --enable-ipset \
 --enable-dnstap --enable-dnscrypt --with-libmnl --enable-subnet --prefix=/usr/local/unboundmm \
 --with-libnghttp2
 make
 make install

cd /usr/local
tar vcJf ./unboundmm.tar.xz unboundmm

mv ./unboundmm.tar.xz /work/artifact/
