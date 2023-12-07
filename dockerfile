FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install -y curl

RUN apt install -y gnupg2 ca-certificates lsb-release ubuntu-keyring

# install nginx
RUN touch /etc/apt/sources.list.d/nginx.list
RUN echo "deb http://nginx.org/packages/ubuntu/ precise nginx" >> /etc/apt/sources.list.d/nginx.list
RUN echo "deb-src http://nginx.org/packages/ubuntu/ precise nginx" >> /etc/apt/sources.list.d/nginx.list
RUN curl http://nginx.org/keys/nginx_signing.key | apt-key add -
RUN apt-get update
RUN apt-get install -y nginx

RUN apt install -y libnss3-tools
RUN service nginx start

ENTRYPOINT ["/bin/sh", "-c", "service nginx start | while :; do sleep 10; done"]
