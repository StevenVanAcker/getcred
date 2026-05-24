FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update
RUN apt-get install -y aptdaemon
RUN mkdir -p /run/dbus

COPY . /opt/getcred
WORKDIR /opt/getcred

RUN dbus-daemon --system --fork && ./install.sh
