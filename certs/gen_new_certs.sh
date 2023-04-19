#!/usr/bin/env bash

PWD="cert@test!"
DAYS=389

for i in *.cnf; do
  CERTNAME=${i%.*}
  if [ "${CERTNAME}" == "ca-root" ] || [ -e "${CERTNAME}".crt ] ; then continue; fi
  echo "Generating new certificate for '${CERTNAME}' ..."

  openssl req -new -newkey rsa:2048 -keyout ${CERTNAME}.key -out ${CERTNAME}.csr -config ${CERTNAME}.cnf -nodes
  openssl x509 -req -days ${DAYS} -in ${CERTNAME}.csr -CA ca-root.crt -CAkey ca-root.key -CAcreateserial -out ${CERTNAME}.crt -extfile ${CERTNAME}.cnf -extensions v3_req

  # show certificate
  echo
  echo "############################"
  echo "Created Certificate:"
  openssl x509 -in ${CERTNAME}.crt -text -subject -issuer

  # Create PEM output required by some services
  openssl pkcs12 -export -in ${CERTNAME}.crt -inkey ${CERTNAME}.key -chain -CAfile ca-root.pem -name fritz.box -out ${CERTNAME}.p12 -password pass:${PWD}
  openssl pkcs12 -in ${CERTNAME}.p12 -out ${CERTNAME}.pem -passin pass:${PWD} -passout pass:${PWD}

  # Create Java Key Store
  

done

