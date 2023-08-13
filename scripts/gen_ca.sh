#!/usr/bin/env bash

[[ -z "${PASSWD}" ]] && echo "No keystore password PASSWD provided - using default 'changeme!'" && PASSWD="changeme!"
[[ -z "${DAYS_CA}" ]] && echo "No validity for CA (DAYS_CA) provided - using default 3650" && DAYS_CA="3650"

if [[ "$PREPARE_CSR_ONLY" != "yes" ]]; then
    # Generate Root CA certificates and concatenate to PEM
    openssl req -new -nodes -x509 -days ${DAYS_CA} -newkey rsa:2048 -keyout current/ca-root.key -out current/ca-root.crt -config current/ca-root.cnf
    cat current/ca-root.crt current/ca-root.key > current/ca-root.pem

    # show certificate
    echo
    echo "############################"
    echo "Created CA:"
    openssl x509 -in current/ca-root.crt -text

    # Create truststore
    keytool -keystore current/truststore.jks -alias CARoot \
    -import -file current/ca-root.crt \
    -storepass ${PASSWD} -noprompt -storetype PKCS12
else
    echo "Skipping CA generation as it is not required for CSR creation..."
fi