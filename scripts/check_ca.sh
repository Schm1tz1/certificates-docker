#!/usr/bin/env bash

# Check if the provided CA Key is "encrypted" - using the first line of the ca-root.key file
first_line=$(head -n 1 /opt/certs/current/ca-root.key)

# Check if the first line contains "ENCRYPTED"
if [[ "$first_line" == *"ENCRYPTED"* ]]; then
    if [[ -z "$CA_KEYPASSWD" ]]; then
        echo "ERROR: The private key is encrypted. The keypass must be provided in the CA_KEYPASSWD environment variable."
        exit 1
    fi
fi

# Capture the modulus of the public certificate
public_modulus=$(openssl x509 -modulus -noout -in /opt/certs/current/ca-root.crt 2>/dev/null | openssl md5)

if [[ -z "$CA_KEYPASSWD" ]]; then
    # Capture the modulus of the private key
    private_modulus=$(openssl rsa -modulus -noout -in /opt/certs/current/ca-root.key 2>/dev/null | openssl md5)
else
    # Capture the modulus of the private key (with password)
    private_modulus=$(openssl rsa -modulus -noout -in /opt/certs/current/ca-root.key -passin pass:$CA_KEYPASSWD 2>/dev/null | openssl md5)
fi

# Compare the two modulis
if [ "$public_modulus" != "$private_modulus" ]; then
    echo "ERROR: Provided CA certificate and key do not match!"
    exit 1
fi

cat current/ca-root.crt > current/ca-root.pem