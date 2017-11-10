FROM alpine:3.2

ENV TINC_VERSION 1.1pre11

RUN apk add --update bash curl zlib-dev lzo-dev openssl-dev build-base tar automake autoconf \
                     ncurses-dev vde2-dev readline-dev linux-headers lzo libpcap libpcap-dev gettext && \
    mkdir -p /app && \
    curl http://www.tinc-vpn.org/packages/tinc-${TINC_VERSION}.tar.gz | tar xzf - -C /app --strip-components=1 && \
    cd /app && \
    sed -i -e 's%AX_CHECK_COMPILE_FLAG(.*)$%/* AC_CHECK_COMPILE_FLAG\\1 */%' configure && \
    sed -i -e 's%AX_CHECK_LINK_FLAG(.*)$%/* AC_CHECK_LINK_FLAG\\1 */%' configure && \
    sed -i -e 's%tinc_ATTRIBUTE(.*)$%/* tinc_ATTRIBUTE\\1 */%' configure && \
    ./configure --prefix=/usr \
		--sysconfdir=/etc \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--enable-jumbograms \
		--disable-hardening \
		--enable-silent-rules \
 		--enable-vde \
		--enable-uml \
		--enable-tunemu \
		--with-openssl-include=/usr/include \
		--with-openssl-lib=/usr/lib && \
    make && \
    make install && \
    rm -fr /app && \
    apk del zlib-dev lzo-dev openssl-dev build-base automake autoconf \
            ncurses-dev vde2-dev readline-dev linux-headers libpcap-dev && \
    rm -rf /var/cache/apk/*

EXPOSE 655/tcp 655/udp

RUN mkdir -p /usr/var/run
VOLUME /etc/tinc

ADD files/ /
RUN find / -name '*.sh' -exec chmod u+x {} \;

CMD bash /tinc.sh
