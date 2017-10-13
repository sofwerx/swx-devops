FROM ubuntu:16.04

ENV DOCKER_HOST unix:///tmp/docker.sock
ENV DOCKER_GEN_VERSION 0.7.1

# TODO: fix this
# HEALTHCHECK --interval=5m --timeout=3s \
#     CMD monero-wallet-cli getinfo || exit 1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y gnupg

ADD docker-apt-install.sh /usr/local/bin/docker-apt-install
RUN docker-apt-install \
    bzip2 \
    ca-certificates \
    curl \
    torsocks

ENV MONERO_VERSION 0.11.0.0

## Monero install from binary
#ENV MONERO_SHA256 fa7742c822f3c966aa842bf20a9920803d690d9db02033d9b397cefc7cc07ff4
#RUN curl -fSL -o monero.tar.bz2 "https://downloads.getmonero.org/cli/monero-linux-x64-v$MONERO_VERSION.tar.bz2" \
# && echo "$MONERO_SHA256 monero.tar.bz2" | sha256sum -c - \
# && tar -xjvf monero.tar.bz2 \
# && cp ./monero-v$MONERO_VERSION/* /usr/local/bin/ \
# && rm -rf monero*

## Monero install from source
RUN apt-get update \
    && apt-get install -y ca-certificates curl iputils-ping numactl \
    && apt-get install -y git build-essential pkgconf cmake g++ libunbound-dev libssl-dev libevent-dev \
        libgtest-dev libdb++-dev libldns-dev libexpat1-dev libbison-dev make \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y libboost-all-dev

RUN git clone https://github.com/monero-project/bitmonero.git /opt/bitmonero \
    && cd /opt/bitmonero \
    && git checkout v$MONERO_VERSION \
    && make -j$(nproc) release-static \
    && mv /opt/bitmonero/build/release/bin/* /usr/local/bin/ \
    && cd / \
    && rm -rf /opt/bitmonero
#    && apt-get install -y libboost1.58-dev libboost1.58-doc libboost-date-time1.58-dev \
#        libboost-chrono1.58-dev libboost-filesystem1.58-dev libboost-program-options1.58-dev \
#        libboost-serialization1.58-dev libboost-system1.58-dev libboost-regex1.58-dev libboost-thread1.58-dev \

RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get -qq update \
 && apt-get install -y --no-install-recommends ca-certificates \
                                               wget \
                                               supervisor \
                                               tor \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup supervisord
ADD files/supervisor/supervisord.conf /etc/supervisor/supervisord.conf

# Install docker-gen
RUN curl -sL https://github.com/jwilder/docker-gen/releases/download/$DOCKER_GEN_VERSION/docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz | \
      tar xvzf - -C /usr/local/bin
# && tar -C /usr/local/bin -xvzf docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz \
# && rm /docker-gen-linux-amd64-$DOCKER_GEN_VERSION.tar.gz

WORKDIR /app

ADD files/docker-gen/torsocks.tmpl /app/torsocks.tmpl
ADD run.sh /app/bin/run.sh

RUN groupadd -g 1000 monero && useradd -m -s /bin/bash -g 1000 -u 1000 -d /home/monero monero

# this config will be setup by the entrypoint script if TOR_HOSTNAME is set
RUN mkdir -p /wallet /home/monero/.bitmonero \
 && touch /etc/tor/torsocks.conf \
 && chown monero:monero /etc/tor/torsocks.conf /wallet /home/monero/.bitmonero


RUN dpkg --search /etc/supervisor/supervisord.conf

# Use the default user that comes with the image
ENV HOME /home/monero
WORKDIR /home/monero

EXPOSE 18080 18081

VOLUME /home/monero/.bitmonero /wallet

ENTRYPOINT ["/app/bin/run.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

