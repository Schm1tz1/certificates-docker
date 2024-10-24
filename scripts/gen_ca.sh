#!/usr/bin/env bash

[[ -z "${DAYS_CA}" ]] && echo "No validity for CA (DAYS_CA) provided - using default 3650" && DAYS_CA="3650"

if [[ "$PREPARE_CSR_ONLY" != "yes" ]]; then
    # Generate Root CA certificates and concatenate to PEM
    openssl req -new -nodes -x509 -days ${DAYS_CA} -newkey rsa:2048 -keyout /mnt/certs/ca-root.key -out /mnt/certs/ca-root.crt -config /mnt/certs/ca-root.cnf
    cat /mnt/certs/ca-root.crt /mnt/certs/ca-root.key > /mnt/certs/ca-root.pem

    # show certificate
    echo
    echo "############################"
    echo "Created CA:"
    openssl x509 -in /mnt/certs/ca-root.crt -text
else
    echo "Skipping CA generation as it is not required for CSR creation..."
fi