FROM ubuntu:16.04

ENV BUILDROOT=/build
ENV BUILDARCH=x86_64
WORKDIR $BUILDROOT

RUN apt-get update && \
    apt-get install -y \
      autoconf \
      automake \
      bsdmainutils \
      build-essential \
      cmake \
      curl \
      g++-multilib \
      g++-4.9 \
      git \
      libboost-all-dev \
      libc6-dev \
      libgmp-dev \
      libgmp3-dev \
      libjansson-dev \
      libleveldb-dev \
      libpcre3-dev \
      libprocps4-dev \
      libprotobuf-dev \
      libssl-dev \
      libsodium-dev \
      libtool \
      m4 \
      make \
      ncurses-dev \
      protobuf-compiler \
      pkg-config \
      python \
      python-markdown \
      python-zmq \
      unzip \
      wget \
      zlib1g-dev

ENV ZCASH_VERSION=v1.0.13

RUN git clone https://github.com/zcash/zcash $BUILDROOT/zcash
WORKDIR $BUILDROOT/zcash
RUN git checkout $ZCASH_VERSION
RUN ./zcutil/fetch-params.sh
RUN ./zcutil/build.sh --disable-rust -j$(nproc)

RUN git clone https://github.com/config4star/config4cpp $BUILDROOT/config4cpp
WORKDIR $BUILDROOT/config4cpp
RUN make -j$(nproc)

RUN git clone https://github.com/google/flatbuffers $BUILDROOT/flatbuffers
WORKDIR $BUILDROOT/flatbuffers/build
RUN cmake ..
RUN make -j$(nproc)
RUN make install

ENV PATH=$BUILDROOT/flatbuffers/build:$PATH

RUN git clone -b version/0.3 https://github.com/eXtremal-ik7/libp2p $BUILDROOT/libp2p
WORKDIR $BUILDROOT/libp2p/$BUILDARCH-Linux
RUN cmake ../src
RUN make -j$(nproc)

RUN git clone https://github.com/eXtremal-ik7/pool_frontend_zcash $BUILDROOT/pool_frontend_zcash

RUN git clone https://github.com/eXtremal-ik7/poolcore $BUILDROOT/poolcore
WORKDIR $BUILDROOT/poolcore/$BUILDARCH-Linux
RUN cmake ../src -DROOT_SOURCE_DIR=$BUILDROOT -DZCASH_ENABLED=1
RUN make -j$(nproc)

WORKDIR $BUILDROOT/pool_frontend_zcash/$BUILDARCH-Linux
RUN cmake ../src -DROOT_SOURCE_DIR=$BUILDROOT
RUN make -j$(nproc)

RUN git clone https://github.com/eXtremal-ik7/poolrestapi $BUILDROOT/poolrestapi
WORKDIR $BUILDROOT/poolrestapi/$BUILDARCH-Linux
RUN cmake ../src -DROOT_SOURCE_DIR=$BUILDROOT
RUN make -j$(nproc)

RUN git clone https://github.com/scipr-lab/libsnark $BUILDROOT/libsnark
WORKDIR $BUILDROOT/libsnark
RUN git submodule update --init --recursive
WORKDIR $BUILDROOT/libsnark/build
RUN cmake ..
RUN make -j$(nproc)
RUN make install

RUN apt-get install -y silversearcher-ag
WORKDIR $BUILDROOT/zcash
RUN patch -p0 < $BUILDROOT/pool_frontend_zcash/pool.diff
RUN sed -i -e "s%LIBZCASH_LIBS = .* -fopenmp%LIBZCASH_LIBS = -lsnark -lgmp -lgmpxx -lboost_system-mt -lcrypto -lsodium -fopenmp -L$BUILDROOT/poolcore/$BUILDARCH-Linux/zcash -lpoolrpczcash -L$BUILDROOT/libp2p/$BUILDARCH-Linux/p2p -lp2p -L$BUILDROOT/libp2p/$BUILDARCH-Linux/asyncio -lasyncio-0.3 -lrt%" Makefile src/Makefile

RUN make -j$(nproc)

ENV NGINX_PREFIX=/usr/local

RUN git clone https://github.com/eXtremal-ik7/ngxrest $BUILDROOT/ngxrest
RUN curl -sL https://nginx.org/download/nginx-1.11.5.tar.gz | tar xzf - -C /build
WORKDIR $BUILDROOT/nginx-1.11.5
RUN ./configure --prefix=$NGINX_PREFIX --add-module=$BUILDROOT/ngxrest
RUN make -j$(nproc)
RUN make install

#RUN git clone https://github.com/eXtremal-ik7/pooljs

