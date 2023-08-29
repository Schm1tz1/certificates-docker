#!/usr/bin/env bash

docker run --rm \
-e PREPARE_CSR_ONLY=yes \
-v $(pwd)/hosts.yml:/opt/certs/hosts.txt \
-v $(pwd)/certs:/opt/certs/current \
schmitzi/openssl-alpine-j11:1.2.0
