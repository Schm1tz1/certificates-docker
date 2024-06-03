#!/usr/bin/env bash

echo "Checking for mandatory input files..."
if [ ! -e /opt/certs/hosts.txt ] ; then 
    echo "Mandatory file /opt/certs/hosts.txt is missing!"
    exit 1
fi

echo "Creating certificate configurations from template..."
./create_configs.py

if [[ "$PREPARE_CSR_ONLY" != "yes" ]]; then
    if [ -e /opt/certs/current/ca-root.crt ] && [ -e /opt/certs/current/ca-root.key ]; then
        echo "Re-using CA that was provided !"
        ./check_ca.sh
    elif [ -e /opt/certs/current/ca-root.crt ] || [ -e /opt/certs/current/ca-root.key ]; then
        echo "ERROR: Missing CA Cert or Key file. Please provide both or none."
        exit 1
    else
        echo "Generating new CA..."
        ./gen_ca.sh
    fi
fi

if [ $? -ne 0 ]; then
    echo "Cannot create certificates. Check for previous errors and correct them before re-running the script"
    exit 1
fi

echo "Creating certificates..."
./gen_new_certs.sh
