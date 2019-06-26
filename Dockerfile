FROM bitnami/minideb:stretch

COPY build.sh /tmp/build.sh
COPY chaperone.conf /etc/chaperone.d/chaperone.conf

RUN /tmp/build.sh && rm /tmp/build.sh

