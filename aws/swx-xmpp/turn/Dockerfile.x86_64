FROM alpine:3.3

ENV COTURN_VERSION 4.5.0.6

RUN apk add --no-cache --update bash curl git make build-base automake autoconf readline readline-dev gettext libcrypto1.0 openssl openssl-dev libevent libevent-dev linux-headers sqlite sqlite-libs sqlite-dev mariadb-libs mysql-dev postgresql postgresql-dev sqlite hiredis hiredis-dev jq && \
    git clone --branch ${COTURN_VERSION} https://github.com/coturn/coturn /build && \
    cd /build && \
    ./configure --prefix=/app && \
    make install && \
    rm -fr /build && \
    apk del hiredis-dev postgresql-dev mysql-dev sqlite-dev linux-headers libevent-dev openssl-dev readline-dev automake autoconf build-base make git && \
    rm -rf /var/cache/apk/*

WORKDIR /app

ADD coturn.sh /coturn.sh
RUN chmod u+rx /coturn.sh

CMD /coturn.sh
