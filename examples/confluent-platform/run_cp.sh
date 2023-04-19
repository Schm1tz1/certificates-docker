#!/usr/bin/env bash

docker run --rm \
-e PASSWD=changeIt -e DAYS=389 -e DAYS_CA=3650 \
-v $(pwd)/hosts.json:/opt/certs/hosts.json \
-v $(pwd)/certs:/opt/certs/current \
schmitzi/openssl-alpine-j11:3.1.7
