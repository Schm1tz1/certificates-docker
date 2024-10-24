#!/usr/bin/env bash

docker run --rm \
-e PASSWD=changeIt -e DAYS=389 -e DAYS_CA=3650 \
-v $(pwd)/hosts.json:/mnt/config/hosts.txt \
-v $(pwd)/certs:/mnt/certs \
schmitzi/openssl-alpine-j11:1.3.0
