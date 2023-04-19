#!/usr/bin/env bash

docker build ./certs -t schmitzi/openssl-alpine-j11:3.1.7 -f Dockerfile
