#!/usr/bin/env bash

CERTDIR="current"
ROOTCA="ca-root"

[[ -z "${DAYS}" ]] && echo "No validity for certs (DAYS) provided - using default 389" && DAYS="389"
[[ -z "${PASSWD}" ]] && echo "No keystore password PASSWD provided - using default 'changeme!'" && PASSWD="changeme!"

for i in ${CERTDIR}/*.cnf; do
  CERTNAME=${i%.*}
  if [ "${CERTNAME}" == "${CERTDIR}/${ROOTCA}" ] || [ -e "${CERTNAME}".csr ] ; then continue; fi

  echo "Generating new private key and CSR for '${CERTNAME}' ..."
  openssl req -new -newkey rsa:2048 -keyout ${CERTNAME}.key -out ${CERTNAME}.csr -config ${CERTNAME}.cnf -nodes

  if [[ "$PREPARE_CSR_ONLY" != "yes" ]]; then
    echo "Generating new certificate for'${CERTNAME}' ..."

    if [[ -z CA_KEYPASSWD ]]; then
      openssl x509 -req -days ${DAYS} -in ${CERTNAME}.csr -CA ${CERTDIR}/${ROOTCA}.crt -CAkey ${CERTDIR}/${ROOTCA}.key -CAcreateserial -out ${CERTNAME}.crt -extfile ${CERTNAME}.cnf -extensions v3_req
    else
      openssl x509 -req -days ${DAYS} -in ${CERTNAME}.csr -CA ${CERTDIR}/${ROOTCA}.crt -CAkey ${CERTDIR}/${ROOTCA}.key -CAcreateserial -out ${CERTNAME}.crt -extfile ${CERTNAME}.cnf -extensions v3_req -passin pass:${CA_KEYPASSWD}
    fi

    # show certificate
    echo
    echo "############################"
    echo "Created Certificate:"
    openssl x509 -in ${CERTNAME}.crt -text -subject -issuer

    # Create PEM output required by some services
    openssl pkcs12 -export -in ${CERTNAME}.crt -inkey ${CERTNAME}.key \
    -chain -CAfile ${CERTDIR}/${ROOTCA}.pem \
    -name $(echo ${i%.*} | cut -d '/' -f2) -out ${CERTNAME}.p12 -password pass:${PASSWD}

    openssl pkcs12 -in ${CERTNAME}.p12 -out ${CERTNAME}.pem -passin pass:${PASSWD} -passout pass:${PASSWD}

    # Create Java Key Store
    keytool -importkeystore -deststorepass ${PASSWD} -destkeystore ${CERTNAME}.keystore.jks \
      -srckeystore ${CERTNAME}.p12 \
      -deststoretype PKCS12  \
      -srcstoretype PKCS12 \
      -noprompt \
      -srcstorepass ${PASSWD}
  fi
done

if [[ "$PREPARE_CSR_ONLY" != "yes" ]]; then
  echo "Creating truststore..."
  # Create truststore
  keytool -keystore current/truststore.jks -alias CARoot \
  -import -file current/ca-root.crt \
  -storepass ${PASSWD} -noprompt -storetype PKCS12
fi
