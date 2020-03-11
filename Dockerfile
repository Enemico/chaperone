FROM bitnami/minideb:buster

COPY build.sh /tmp/build.sh
COPY chaperone.conf /etc/chaperone.d/chaperone.conf

RUN /tmp/build.sh && rm /tmp/build.sh

