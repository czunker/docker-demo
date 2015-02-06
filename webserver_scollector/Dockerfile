# Dockerfile for simple python webserver
# Version 1.0
FROM lukaspustina/docker_demo_webserver

MAINTAINER Christian Zunker <christian.zunker@codecentric.de>

RUN mkdir /opt/scollector

ADD scollector-linux-amd64 /opt/scollector/scollector

RUN chmod +x /opt/scollector/scollector
#RUN /opt/scollector/scollector -h localhost:8070
#RUN /opt/webserver/run.sh
