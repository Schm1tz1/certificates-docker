FROM alpine:3.17
LABEL maintainer="roman.schmitz@gmail.com"
LABEL summary="OpenSSL3/Alpine"
RUN apk add openssl3 bash openjdk11
