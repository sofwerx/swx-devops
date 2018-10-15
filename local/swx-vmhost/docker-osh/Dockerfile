FROM ubuntu:latest

# expose port for OSH Server
EXPOSE 8181

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
# no more 7, hope 8 works
#  openjdk-7-jdk \
  openjdk-8-jdk \
  && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /opt

RUN curl -sL https://github.com/opensensorhub/osh-core/releases/download/v1.3.1/osh-base-install-1.3.1.zip | unzip osh-base-install-1.3.1.zip | sudo -E bash - 

WORKDIR /opt/osh-base-install-1.3.1

#ADD run.sh /run.sh

# run it!
CMD ./launch.sh

