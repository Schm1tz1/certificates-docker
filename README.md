### OpenSSL Scripts for CA and Local Certificate Creation in Docker
This repo is used to create certificatges by a trusted CA (either provided or generated here). Configuration will be completely done based on a Jinja2-template and a JSON-configuration that is used for the certificate creation. Several key types, Java trust-/keystores will be created automatically in addition.

We are using a Docker-based approach to ensure we are using the correct versions (JDK 11, OpenSSL 3).

Typical issues / errors:
* max. validity as of 2020-09-01 is 389 days (default). Higher values will have issues on certificate validation. 
* SHA1 is deprecated. Depending on the OpenSSL implementation even though SHA256 is configured it sometimes creates SHA1 certificates that are not accepted by today's browsers.  

Steps to create you certificate (with docker):
* Look at the [examples](./examples) and try it!
* Create a JSON-file `hosts.json` that contains one object for each certificate in an array `certs`. Example:
```json
{
    "certs": [
        {
            "fileName": "ca-root.cnf",
            "country": "DE",
            "org": "My Org",
            "locality": "Berlin",
            "CN": "me.at.home",
            "CA": "true"
        },
        {
            "fileName": "test.cnf",
            "country": "DE",
            "org": "My Org",
            "locality": "Berlin",
            "CN": "me.at.home",
            "CA": "false",
            "SANs": [
                {"name": "127.0.0.1"},
                {"name": "127.0.1.1"},
                {"name": "10.0.0.1"}
            ]
        }
    ]
}
```
Description of the fields:
| Field | Description |
|---|---|
| fileName  | Output filename for the certificate configuration (*.cnf). CSR/Certificates/Keys will have the suffix .crt/.csr/.pem and so on and the prefix will also be used as an alias in keystores |
| country | Certificate countryName |
| org | Certificate organizationName | 
| locality | Certificate localityName (e.g. location, city...) |
| CN | Certificate commonName (Should match host name !) |
| CA | Is this certificate a CA - true/false |
| SANs | List of alternative IPs / hostnames to be added as Subject Alternative Names |

* Pull the docker image (from docker hub) or build locally with `./build_docker_image.sh`
* Run the docker image - you need to mount the `hosts.json` to `/opt/certs/hosts.json` and a destination directory where the configs and certificates will be placed to `/opt/certs/current` - e.g.:
```bash
docker run --rm \
-v $(pwd)/hosts.json:/opt/certs/hosts.json \
-v $(pwd)/certs:/opt/certs/current \
schmitzi/openssl-alpine-j11:3.1.7
```
* The following optional parameters can be provided as environment variables using `-e`:

| Variable | Description | Default |
|---|---|---|
| PASSWD  | Password for keystores / containers | changeme! |
| DAYS_CA | Validity for CA in days | 3650 |
| DAYS | Validity for certificates in days | 389 |
