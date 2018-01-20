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
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
  && apt-get install -y -q nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# RUN apt-get install graphicsmagick
# https://raw.githubusercontent.com/sofwerx/swx-devops/master/aws/swx-geotools1/docker-mage-server/GraphicsMagick.tar.gz
RUN curl https://raw.githubusercontent.com/sofwerx/swx-devops/master/aws/swx-geotools1/docker-mage-server/graphicsmagick.tar.gz | tar xvf -
WORKDIR GraphicsMagick-1.3.27
RUN make install

RUN mkdir -p /opt
WORKDIR /opt
RUN curl https://codeload.github.com/ngageoint/mage-server/zip/master > mage-server.zip
RUN unzip mage-server.zip
RUN mv mage-server-master mage-server
WORKDIR /opt/mage-server

RUN npm install
RUN mkdir -p /var/lib/mage

# start MongoDB
RUN mongod --config /etc/mongodb.conf

# MAGE database setup
RUN npm run migrate

# install web dependencies
RUN npm run build

RUN npm install -g forever

# run it!
CMD ["forever", "start app.js"]

