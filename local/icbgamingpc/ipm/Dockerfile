FROM node:9.2.0

# build and install
RUN npm i -g iota-pm

EXPOSE 8888

CMD ["iota-pm", "-i",  "http://172.18.0.1:14265", "-p", "0.0.0.0:8888"]

