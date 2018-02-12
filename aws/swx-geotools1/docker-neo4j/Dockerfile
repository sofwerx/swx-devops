FROM ubuntu:latest

# Install basics
RUN apt-get -q update && apt-get install -y -qq \
  git \
  curl \
  gcc \
  make \
  build-essential \
  software-properties-common \
  sudo \
  apt-utils \
  unzip \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
  && apt-get install -y -q nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/adadgio/neo4j-js-ng2.git /neo4j-js-ng2

WORKDIR /neo4j-js-ng2

RUN npm install
RUN npm install -g angular-cli

COPY ./neo4j.settings.json /neo4j-js-ng2/support
#RUN mv support/neo4j.settings.json.dist support/neo4j.settings.json

RUN npm build

# http://localhost:4200

EXPOSE 4200
EXPOSE 49153
WORKDIR /neo4j-js-ng2/dist
CMD npm start

