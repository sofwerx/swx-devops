FROM ubuntu:latest

# expose port for MAGE Server
EXPOSE 4242

# install basics
RUN apt-get -q update && apt-get install -y -qq \
  git \
  curl \
  ssh \
  gcc \
  make \
  build-essential \
  sudo \
  apt-utils \
  unzip \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
  && apt-get install -y -q nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
RUN echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
RUN apt-get update
RUN apt-get install -y --allow-unauthenticated mongodb-org

RUN mkdir -p /opt/src
WORKDIR /opt/src

RUN curl https://raw.githubusercontent.com/sofwerx/swx-devops/master/aws/swx-geotools1/docker-mage-server/graphicsmagick-src.tar.xz | tar xvfJ -
WORKDIR GraphicsMagick-1.3.27
RUN ./configure
RUN make

WORKDIR /opt
ENV MAGE_VERSION=5.0.0
RUN git clone -b ${MAGE_VERSION} --depth 1 https://github.com/ngageoint/mage-server
WORKDIR mage-server

RUN npm install
RUN mkdir -p /var/lib/mage

# install web dependencies
RUN echo '{ "allow_root": true }' > ~/.bowerrc
RUN npm run build

RUN npm install -g forever

ADD run.sh /run.sh

VOLUME /var/lib/mage

# run it!
CMD /run.sh

