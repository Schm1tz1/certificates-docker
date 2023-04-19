#!/usr/bin/env python3
import jinja2
import json

with open('./hosts.json') as json_file:
    hosts = json.load(json_file)

templateLoader = jinja2.FileSystemLoader(searchpath="./")
templateEnv = jinja2.Environment(loader=templateLoader)
template = templateEnv.get_template("cert.template")

for host in hosts['certs']:
    print("\nInput variables: \n", host)
    outputCertConfig = template.render(host)
    print("\nCertificate Config: \n ", outputCertConfig)

    with open('./current/'+host['fileName'], "w") as out_file:
        out_file.write(outputCertConfig)
