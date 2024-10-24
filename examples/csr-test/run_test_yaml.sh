#!/usr/bin/env bash

docker run --rm \
-e PREPARE_CSR_ONLY=yes \
-v $(pwd)/hosts.yml:/mnt/config/hosts.txt \
-v $(pwd)/certs:/mnt/certs \
schmitzi/openssl-alpine-j11:1.3.0
