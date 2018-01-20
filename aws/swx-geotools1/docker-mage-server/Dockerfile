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
RUN curl https://codeload.github.com/ngageoint/mage-server/zip/master > mage-server.zip
RUN unzip mage-server.zip
RUN mv mage-server-master mage-server
WORKDIR /opt/mage-server

RUN npm install
RUN mkdir -p /var/lib/mage

# start MongoDB
#RUN /usr/bin/mongod --config /etc/mongodb.conf
RUN service mongod start

# MAGE database setup
RUN npm run migrate

# install web dependencies
RUN npm run build

RUN npm install -g forever

# run it!
CMD ["forever", "start app.js"]

