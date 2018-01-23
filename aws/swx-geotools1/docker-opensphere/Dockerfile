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

# Install Java
RUN apt-add-repository ppa:openjdk-r/ppa \
 && apt-get update \
 && apt-get -y install openjdk-8-jdk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Export JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Install node.js
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
  && apt-get install -y -q nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update \
    && apt-get install -y yarn \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN git clone https://github.com/ngageoint/opensphere-yarn-workspace /opensphere-yarn-workspace

RUN git clone https://github.com/ngageoint/opensphere /opensphere-yarn-workspace/workspace/opensphere

WORKDIR /opensphere-yarn-workspace/workspace/opensphere

#RUN yarn install
RUN npm install

# http://localhost:8282/opensphere
# http://localhost:8282/opensphere/dist/opensphere

RUN npm run build

RUN npm install http-server -g

EXPOSE 8282
CMD npm run start-server

