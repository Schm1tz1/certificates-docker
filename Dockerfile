FROM alpine:3.18
LABEL maintainer="roman.schmitz@gmail.com"
LABEL summary="Certificate Builder based on OpenSSL3/Alpine"

RUN apk update \
  && apk upgrade \
  && apk add --update bash openjdk11-jre-headless~11.0 openssl3 py3-jinja2 py3-yaml\
  && rm -rf /var/cache/apk/*

RUN mkdir -p /opt/scripts

COPY *.sh /opt/scripts
COPY create_configs.py /opt/scripts
COPY cert.template /opt/scripts

WORKDIR /opt/scripts
ENV CERTDIR=/mnt/certs

CMD ["/opt/scripts/run.sh"]
