FROM alpine:3.17
LABEL maintainer="roman.schmitz@gmail.com"
LABEL summary="Certificate Builder based on OpenSSL3/Alpine"

RUN apk update \
  && apk upgrade \
  && apk add --update bash openjdk11-jre-headless~11.0 openssl3 py3-jinja2 py3-yaml\
  && rm -rf /var/cache/apk/*

RUN mkdir -p /opt/certs

ADD *.sh /opt/certs/
ADD create_configs.py /opt/certs/
ADD cert.template /opt/certs/
WORKDIR /opt/certs

CMD ["/opt/certs/run.sh"]
