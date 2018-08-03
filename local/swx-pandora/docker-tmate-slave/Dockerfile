FROM ubuntu:xenial

RUN apt-get update
RUN apt-get install -y git-core build-essential pkg-config libtool libevent-dev libncurses-dev zlib1g-dev automake libssh-dev cmake ruby

RUN git clone https://github.com/tmate-io/tmate-slave.git /tmate-slave

WORKDIR /tmate-slave

RUN apt-get install -y curl

RUN curl -sLo /tmp/msgpack-1.3.0.tar.gz https://github.com/msgpack/msgpack-c/releases/download/cpp-1.3.0/msgpack-1.3.0.tar.gz \
 && mkdir -p /usr/src/msgpack \
 && tar zxf /tmp/msgpack-1.3.0.tar.gz --strip-components 1 -C /usr/src/msgpack \
 && cd /usr/src/msgpack \
 && ./configure --prefix=/usr \
 && make \
 && make install \
 && rm -fr /tmp/msgpack-1.3.0.tar.gz /usr/src/msgpack

RUN git clone https://github.com/nviennot/libssh.git /usr/src/libssh-git \
 && cd /usr/src/libssh-git \
 && git checkout v0-7 \
 && mkdir -p build \
 && cd build \
 && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DWITH_EXAMPLES=OFF -DWITH_SFTP=OFF .. \
 && make \
 && make install \
 && cd / \
 && rm -fr /usr/src/libssh-git

RUN ./autogen.sh \
 && ./configure \
 && make

ENV TMATE_PORT=10022 \
    TMATE_HOST=localhost \
    TMATE_KEYS_DIR=/keys

ADD run.sh /run.sh

VOLUME /keys

CMD /run.sh

