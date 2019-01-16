FROM ubuntu:16.04

RUN apt-get update \
 && apt-get install -y sudo wget

ADD dependencies/ubuntu.sh /ubuntu.sh

RUN /ubuntu.sh

RUN mkdir /swx
WORKDIR /swx

VOLUME /swx

CMD screen -a -A -fn -h 10000 -s swx-devops ./shell.bash
