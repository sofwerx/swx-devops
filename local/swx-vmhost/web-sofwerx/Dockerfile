# alpine:latest has ssl pkg conflict weirdness (20 June 2019), 3.8 does not
FROM alpine:3.8

# workaround for failing InnoDB database initialization using MariaDB 10.2.x & up (tried 10.3.15)
# ref: https://bugs.alpinelinux.org/issues/9046
#RUN echo "http://dl-5.alpinelinux.org/alpine/v3.7/main" >> /etc/apk/repositories
#RUN echo -e "mariadb<10.1.99\nmariadb-client<10.1.99\nmariadb-common<10.1.99" >> /etc/apk/world
RUN apk update && apk add nginx && mkdir -p /run/nginx /www/data
RUN apk add bash && \
    apk add imagemagick && \
    apk add ghostscript && \
    apk add php && apk add php-pear && apk add php-fpm && apk add php-mysqli
#RUN pecl install imagick

COPY nginx-default.conf /etc/nginx/conf.d/default.conf
COPY php-fpm-www.conf /etc/php7/php-fpm.d/www.conf

EXPOSE 80/tcp
EXPOSE 9000/tcp

#ENTRYPOINT ["/usr/sbin/nginx", "-q", "-g", "daemon off;"]

#CMD ["/bin/sh", "-c", "chown -R mysql.mysql /www/database; /usr/bin/mysqld_safe --defaults-file=/www/database/my.cnf --datadir=/www/database/data & /usr/sbin/php-fpm7; exec nginx -g 'daemon off;';"]

CMD ["/bin/sh", "-c", "/usr/sbin/php-fpm7; exec nginx -g 'daemon off;';"]
