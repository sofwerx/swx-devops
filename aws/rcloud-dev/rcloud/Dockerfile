FROM rocker/drd

MAINTAINER "Ian Blenke <ian@sofwerx.org>"

ENV DEBIAN-FRONTEND noninteractive
ENV ROOT /data/rcloud

RUN apt-get update \
  && apt-get install -y -t unstable --no-install-recommends \
  libcairo2 \
  libpng-dev \
  libboost-dev \
  libxt-dev \
  libcairo2-dev \
  libxml2-dev \
  libcurl4-openssl-dev \
  ca-certificates \
  file \
  git \
  libssl1.0.2 \
  libapparmor1 \
  libedit2 \
  libssl-dev \
  sudo \
  curl \
  python-dev \
  python-zmq \
  ipython \
  python-matplotlib \
  git procps lsof net-tools

## A default user system configuration. For historical reasons,
## we want user to be 'rcloud', but it is 'docker' in r-base
RUN usermod -l rcloud docker \
  && usermod -m -d /home/rcloud rcloud \
  && groupmod -n rcloud docker \
  && echo '"\e[5~": history-search-backward' >> /etc/inputrc \
  && echo '"\e[6~": history-search-backward' >> /etc/inputrc \
  && echo "rcloud:rcloud" | chpasswd

## Create RCloud project folder

RUN mkdir -p /data/rcloud && \
    mkdir -p /data/rcloud/data/gists && \
    chmod -R a+rwx /data/rcloud/data

## Get Pandoc
RUN cd /tmp \
    && wget https://s3.amazonaws.com/rstudio-buildtools/pandoc-1.13.1.zip \
    && unzip ./pandoc-1.13.1.zip \
    && cp pandoc-1.13.1/linux/debian/x86_64/* /usr/local/bin/ \
    && rm -rf pandoc-1.13.1

RUN git clone -b hotfix/1.8.1 https://github.com/att/rcloud /src \
    && cd /src \
    && cp -a conf /data/rcloud/conf \
    && cp -a htdocs /data/rcloud/htdocs \
    && cp -a packages /data/rcloud/packages \
    && cp -a rcloud.client /data/rcloud/rcloud.client \
    && cp -a rcloud.packages /data/rcloud/rcloud.packages \
    && cp -a rcloud.support /data/rcloud/rcloud.support \
    && cp -a scripts /data/rcloud/scripts \
    && cp -a tests /data/rcloud/tests \
    && cp -a VERSION /data/rcloud/VERSION \
    && cp -a package.json /data/rcloud/package.json \
    && cp -a Gruntfile.js /data/rcloud/Gruntfile.js \
    && cp -a docker /data/rcloud/docker \
    && cd /tmp \
    && rm -fr /tmp/rcloud

ADD domainCookie.patch /data/rcloud/docker/domainCookie.patch
RUN cd /data/rcloud && git apply docker/domainCookie.patch
RUN cd /data/rcloud \
    && scripts/bootstrapR.sh \
    && scripts/build.sh --all

#RUN cd $ROOT/services/SessionKeyServer \
#    && make pam

RUN cd /data/rcloud/conf/solr \
    && sh solrsetup.sh /data/rcloud/services

## Get rcloud extention modules
RUN cd /data/rcloud/rcloud.packages \
    && git clone https://github.com/att/rcloud.shiny.git \
    && git clone https://github.com/att/rcloud.params.git \
    && git clone https://github.com/att/rcloud.logo.git \
    && git clone https://github.com/att/rcloud.dcplot.git \
    && git clone https://github.com/att/rcloud.htmlwidgets.git \
    && git clone https://github.com/att/rcloud.rmd.git \
    && git clone https://github.com/att/rcloud.flexdashboard.git \
    && R -e "install.packages(c('rcloud.shiny','rpython2'),repos=c('http://rforge.net','http://r.research.att.com'))"

RUN cd /src \
    && cp -f docker/rcloud.conf /data/rcloud/conf \
    && cp -f docker/init.sh /bin \
    && cp -f docker/index.html /data/rcloud/htdocs \
    && cp -f docker/dockerbye.R /data/rcloud/htdocs

RUN chown -R rcloud:rcloud /data/rcloud

EXPOSE 8080

WORKDIR /data/rcloud

ADD init.sh /bin/init.sh

VOLUME /data/rcloud/conf
VOLUME /data/rcloud/data

CMD /bin/init.sh
