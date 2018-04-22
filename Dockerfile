FROM ubuntu:xenial

RUN apt-get update && apt-get install -y software-properties-common
RUN apt-get update
RUN apt-get install -y mariadb-server wget tomcat7 librxtx-java
COPY ScadaBR.war /root
COPY configure_and_start.sh /root

CMD /root/configure_and_start.sh > /root/install.log && tail -f /dev/null
