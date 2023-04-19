#!/usr/bin/env bash

CERTDIR="current"
ROOTCA="ca-root"

[[ -z "${DAYS}" ]] && echo "No validity for certs (DAYS) provided - using default 389" && DAYS="389"
[[ -z "${PASSWD}" ]] && echo "No keystore password PASSWD provided - using default 'changeme!'" && PASSWD="changeme!"

for i in ${CERTDIR}/*.cnf; do
  CERTNAME=${i%.*}
  if [ "${CERTNAME}" == "${CERTDIR}/${ROOTCA}" ] || [ -e "${CERTNAME}".crt ] ; then continue; fi
  echo "Generating new certificate '${CERTNAME}' ..."

  openssl req -new -newkey rsa:2048 -keyout ${CERTNAME}.key -out ${CERTNAME}.csr -config ${CERTNAME}.cnf -nodes
  openssl x509 -req -days ${DAYS} -in ${CERTNAME}.csr -CA ${CERTDIR}/${ROOTCA}.crt -CAkey ${CERTDIR}/${ROOTCA}.key -CAcreateserial -out ${CERTNAME}.crt -extfile ${CERTNAME}.cnf -extensions v3_req

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

done
