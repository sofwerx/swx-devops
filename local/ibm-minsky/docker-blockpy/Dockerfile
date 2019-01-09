FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y wget curl python-dev python-pip build-essential unzip git

RUN git clone https://github.com/RealTimeWeb/blockpy.git
WORKDIR blockpy
RUN git clone https://github.com/pgbovine/OnlinePythonTutor.git python-tutor
RUN git remote add blockly https://github.com/RealTimeWeb/blockly \
 && git remote add blockly_upstream https://github.com/google/blockly.git \
 && git remote add skulpt https://github.com/RealTimeWeb/skulpt.git \
 && git remote add skulpt_upstream https://github.com/skulpt/skulpt.git \
 && git remote add server https://github.com/RealTimeWeb/Blockpy-Server.git \
 && git remote add blockly_games https://github.com/RealTimeWeb/blockly-games.git
RUN git fetch --all

#RUN set -x \
# && git subtree pull --prefix=skulpt --squash skulpt_upstream master \
# && git subtree pull --prefix=blockly --squash blockly_upstream master \
# && git subtree pull --prefix=server --squash server master \
# && mkdir -p server/static \
# && git subtree pull --prefix=server/static/blockly-games --squash blockly_games master \
# && echo "Done"

RUN git clone https://github.com/google/closure-library

# Build blockly
RUN cp blockly/msg/js/en.js en.js \
 && cd blockly \
 && python build.py \
 && cd .. \
 && mv en.js blockly/msg/js/en.js

# Build skulpt
#RUN cd skulpt \
# && python skulpt.py dist

#CMD python manage.py runserver

RUN pip install flask

RUN sed -i -e "s/port=8000/host='0.0.0.0',port=8000/" example_server.py

EXPOSE 8000

CMD python example_server.py runserver
