#!/usr/bin/env bash

echo "Checking for mandatory input files..."
if [ ! -e /opt/certs/hosts.json ] ; then 
    echo "Mandatory file /opt/certs/hosts.json is missing!"
    exit 1
fi

echo "Creating certificate configurations from template..."
./create_configs.py

echo "Checking for existing root CA and creating one otherwise..."
if [ -e /opt/certs/current/ca-root.crt ] ; then 
    echo "Re-using CA that was provided !"
else
    ./gen_ca.sh
fi

echo "Creating certificates..."
./gen_new_certs.sh
