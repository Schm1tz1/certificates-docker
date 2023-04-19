#!/usr/bin/env bash

docker run --rm -it -v $(pwd)/certs:/certs -w /certs schmitzi/openssl-alpine-j11:3.1.7 ./gen_ca.sh
