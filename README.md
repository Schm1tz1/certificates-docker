### OpenSSL Scripts for CA and Local Certificate Creation in Docker
In this repo we create a local CA and a TLS certificate trusted by this CA. You only need to trust the CA so no need to update your clients everytime the certificate is renewed. Java truest-/keystores will be created automatically in addition.

We are using a Docker-based approach to ensure we are using the correct versions (JDK 11, OpenSSL 3).

Typical issues / errors:
* max. validity as of 2020-09-01 is 389 days (default). Higher values will have issues ion certificate validation. 
* SHA1 is deprecated. Depending on the OpenSSL implementation even though SHA256 is configured it sometimes creates SHA1 certificates that are not accepted by today's browsers.  

Steps to create you certificate (with docker):
* Adapt the configs for CA and your servers/clients (`*.cnf`)
* Create the Docker image: `docker build ./certs -t openssl-j11:3.0.0 -f Dockerfile` or `./build_image.sh`
* If needed, create the CA: `./gen_ca_docker.sh`
* Create the Certificates: `./gen_certs_docker.sh`
* Trust your CA locally
  * Linux (Debian/Ubuntu)
    ```
    apt install ca-certificates
    # Copy your CA to dir /usr/local/share/ca-certificates/
    sudo cp foo.crt /usr/local/share/ca-certificates/foo.crt
    sudo update-ca-certificates
    # To remove/rebuild
    sudo update-ca-certificates --fresh
    ```
  * MacOS
    ```
    sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ~/new-root-certificate.crt
    sudo security delete-certificate -c "<name of existing certificate>"
    ```
    Or via App Keychain Access: File/Import Items->Import Certificate, open and trust always
  * Windows
    ```
    certutil -addstore -f "ROOT" new-root-certificate.crt
    certutil -delstore "ROOT" serial-number-hex
    ```