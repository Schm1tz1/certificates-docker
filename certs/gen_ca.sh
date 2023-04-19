#!/usr/bin/env bash

# Generate Root CA certificates and concatenate to PEM
openssl req -new -nodes -x509 -days 3650 -newkey rsa:2048 -keyout ca-root.key -out ca-root.crt -config ca-root.cnf
cat ca-root.crt ca-root.key > ca-root.pem

# show certificate
echo
echo "############################"
echo "Created CA:"
openssl x509 -in ca-root.crt -text | less
