### OpenSSL-based Certificate Preparation / Creation in Docker
This repo is used to prepare (for signing with an external CA service) or create certificates by a trusted CA (either provided or generated in the same step). Configuration will be completely done based on a Jinja2-template and a host configuration in YAML or JSON that is used for the certificate creation. Several key types, Java trust-/keystores will be created automatically in addition.

We are using a Docker-based approach to ensure that the correct versions are used (e.g. JDK 11, OpenSSL 3).

Typical issues / errors:
* max. validity as of 2020-09-01 is 389 days (default). Higher values will have issues on certificate validation. 
* SHA1 is deprecated. Depending on the OpenSSL implementation even though SHA256 is configured it sometimes creates SHA1 certificates that are not accepted by today's browsers.  

Steps to create you certificate (with docker):
* Look at the [examples](./examples) and try it!
* Create a YAML/JSON-file `hosts.txt` that contains one `global` object with variables that apply to all certificates and a list of objects for each certificate in `certs`. You **can** create wildcard certificates, be aware that asterisk * is a special character so it needs to be in double quotes in YAML. Example:
```yaml
global:
  country: DE
  org: My Org
  orgUnit: Special Unit
  state: BER
  locality: Berlin
certs:
  - fileName: ca-root
    CN: me.at.home
    CA: "true"
  - fileName: test
    CN: at.home
    CA: "false"
    SANs:
      - name: "*.at.home"
  - fileName: test
    CN: me.at.home
    CA: "false"
    SANs:
      - name: localhost
      - ip: 127.0.1.1
      - ip: 10.0.0.1
```
OR
```json
{
    "global": {
        "country": "DE",
        "org": "My Org",
        "locality": "Berlin"
    },
    "certs": [
        {
            "fileName": "ca-root",
            "CN": "me.at.home",
            "CA": "true"
        },
        {
            "fileName": "test",
            "CN": "me.at.home",
            "CN_as_SAN": "false",
            "CA": "false",
            "SANs": [
                {"name": "localhost"},
                {"ip": "127.0.1.1"},
                {"ip": "10.0.0.1"}
            ]
        },
        {
            "CN": "me.at.home",
            "SANs": [
                {"ip": "10.0.0.2"}
            ]
        }
    ]
}
```
Description of the fields:
| Field | Description |
|---|---|
| fileName  | Output base filename for the certificate configuration IF different from the CN. Config/CSR/Certificates/Keys will have the suffix .cnf/.crt/.csr/.pem and so on and the base name will also be used as an alias in keystores. (default: value of CN) |
| country | Certificate countryName (default: DE) |
| state | Certificate stateOrProvinceName (default: BER) |
| org | Certificate organizationName (default: Schm1tz1) | 
| orgUnit | Certificate organizationalUnitName (default: IT) | 
| locality | Certificate localityName (e.g. location, city...) (default: Berlin) |
| CN | Certificate commonName (Should match host name !) (default: schm1tz1.github.io) |
| CA | Is this certificate a CA - true/false (default: false) |
| SANs | List of alternative IPs / hostnames to be added as Subject Alternative Names by hostname (name) or IP (ip)|
| CN_as_SAN | Add CN as SAN in addition (required by many clients/browsers) - true/false (default: true) |

* Pull the docker image (from docker hub) or build locally with `./build_docker_image.sh`
* Run the docker image - you need to mount the `hosts.txt` to `/mnt/config/hosts.txt` and a destination directory where the configs and certificates will be placed to `/mnt/certs` - e.g.:
```bash
docker run --rm \
-v $(pwd)/hosts.txt:/mnt/config/hosts.txt \
-v $(pwd)/certs:/mnt/certs \
schmitzi/openssl-alpine-j11:1.0.0
```
* The following optional parameters can be provided as environment variables using `-e`:

| Variable | Description | Default |
|---|---|---|
| PREPARE_CSR_ONLY  | Create private key and CSR only instead on generating the full certificates. This is iseful when preparing a CSR for external (paid) certificate services that require you to provide a CSR and will return the signed certificate. Valid values: yes/no | no |
| PASSWD  | Password for keystores / containers | changeme! |
| DAYS_CA | Validity for CA in days | 3650 |
| DAYS | Validity for certificates in days | 389 |
| CA_KEYPASSWD | Password for CA private key |  |

* Please note: Only new certificates will be created in the existing directory - if a .csr file exists already, it will not be overwritten !
* How to provide an existing CA - simply put the following files in your certificate/output directory
    * `ca-root.crt`: certificate im PEM format
    * `ca-root.key`: private key (preferrably unencrypted)
    * `ca-root.pem`: (full-chain) PEM of the private key and CA certificate(s)
