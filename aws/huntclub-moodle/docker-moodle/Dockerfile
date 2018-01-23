FROM ubuntu:16.04

ENV MOODLE_URL http://127.0.0.1

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install \
      mysql-client pwgen python-setuptools curl git unzip apache2 php \
      php-gd libapache2-mod-php postfix wget supervisor php-pgsql curl libcurl3 \
      libcurl3-dev php-curl php-xmlrpc php-intl php-mysql git-core php-xml php-mbstring php-zip php-soap cron php7.0-ldap \
 && apt-get clean autoclean \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

RUN rm -fr /var/www/html \
 && git clone -b MOODLE_34_STABLE --depth=1 git://git.moodle.org/moodle.git /var/www/html/

# Install some modules we need

# https://moodle.org/plugins/mod_attendanceregister
RUN git clone -b MOODLE_27_STABLE --depth=1 https://github.com/CinecaElearning/moodle-mod_attendanceregister  /var/www/html/mod/moodle-mod_attendanceregister

# https://moodle.org/plugins/qbehaviour_interactivehints
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install mercurial \
 && apt-get clean autoclean \
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*
RUN hg clone https://bitbucket.org/oasychev/moodle-plugins /tmp/moodle_plugins \
 && mkdir -p /var/www/html/question/behaviour/ \
 && mv /tmp/moodle_plugins/question/behaviour/interactivehints /var/www/html/question/behaviour/interactivehints \
 && rm -fr /tmp/moodle_plugins

# https://moodle.org/plugins/mod_vpl
RUN git clone -b v3.3.2 https://github.com/jcrodriguez-dis/moodle-mod_vpl /var/www/html/mod/moodle-mod_vpl

# https://moodle.org/plugins/mod_treasurehunt
RUN git clone -b release/v1.2.12 https://github.com/juacas/moodle-mod_treasurehunt /var/www/html/mod/moodle-mod_treasurehunt

RUN chown -R www-data:www-data /var/www/html

ADD ./phpinfo.php /var/www/html/phpinfo.php

ADD ./foreground.sh /etc/apache2/foreground.sh

#cron
COPY moodlecron /etc/cron.d/moodlecron
RUN chmod 0644 /etc/cron.d/moodlecron

COPY moodle-config.php /var/www/html/config.php

# Enable SSL, moodle requires it
#RUN a2enmod ssl && a2ensite default-ssl  #if using proxy dont need actually secure connection

EXPOSE 80 443
VOLUME ["/var/moodledata"]

CMD ["/etc/apache2/foreground.sh"]
