FROM guacamole/guacamole

RUN apt-get update ; apt-get install -y postgresql-client

ADD start.sh /opt/guacamole/bin/start.sh
ADD run.sh /run.sh

CMD /run.sh

