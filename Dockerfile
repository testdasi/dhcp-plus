ARG FRM='testdasi/dhcp-plus-base'
ARG TAG='latest'
ARG DEBIAN_FRONTEND='noninteractive'

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG

ENV WEBMIN_PASSWORD password
ENV DEFAULT_SUBNET 192.168.1.0
ENV DEFAULT_NETMASK 255.255.255.0

## build note ##
RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM}:${TAG}" >> /build.info

ADD stuff /dhcp-plus

## install static codes ##
RUN rm -Rf /testdasi \
    && mkdir -p /temp \
    && cd /temp \
    && curl -sL "https://github.com/testdasi/static-ubuntu/archive/main.zip" -o /temp/temp.zip \
    && unzip /temp/temp.zip \
    && rm -f /temp/temp.zip \
    && mv /temp/static-ubuntu-main /testdasi \
    && rm -Rf /testdasi/deprecated

## execute execute execute ##
RUN /bin/bash /testdasi/scripts-install/install-dhcp-plus.sh

## debug mode (comment to disable) ##
RUN /bin/bash /testdasi/scripts-install/install-debug-mode.sh
#ENTRYPOINT ["tini", "--", "/entrypoint.sh"]

## Final clean up ##
#RUN rm -Rf /testdasi

## VEH ##
VOLUME ["/etc/webmin", "/etc/dhcp"]
ENTRYPOINT ["tini", "--", "/dhcp-plus/entrypoint.sh"]
#HEALTHCHECK CMD /static-ubuntu/openvpn-client/healthcheck.sh
