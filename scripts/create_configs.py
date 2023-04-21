#!/usr/bin/env python3
import jinja2
import yaml

# Read hosts input and extract global settings
with open('./hosts.txt') as input_file:
    hosts = yaml.load(input_file, Loader=yaml.FullLoader)
globals = hosts['global'] if 'global' in hosts else {}

templateLoader = jinja2.FileSystemLoader(searchpath="./")
templateEnv = jinja2.Environment(loader=templateLoader, extensions=['jinja2.ext.do'])
template = templateEnv.get_template("cert.template")

for host in hosts['certs']:
    print("\nInput variables: \n", host)
    outputCertConfig = template.render(host | globals)
    print("\nCertificate Config: \n ", outputCertConfig)

    output_filename = host['fileName']+'.cnf' if 'fileName' in host else host['CN']+'.cnf'
    
    with open('./current/'+output_filename, "w") as out_file:
        out_file.write(outputCertConfig)
