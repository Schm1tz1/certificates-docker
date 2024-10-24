#!/usr/bin/env bash

echo "Checking for mandatory input files..."
if [ ! -e /mnt/config/hosts.txt ] ; then 
    echo "Mandatory file /mnt/config/hosts.txt is missing!"
    exit 1
fi

echo "Creating certificate configurations from template..."
./create_configs.py

if [[ "$PREPARE_CSR_ONLY" != "yes" ]]; then
    if [ -e /mnt/certs/ca-root.crt ] && [ -e /mnt/certs/ca-root.key ]; then
        echo "Re-using CA that was provided !"
        ./check_ca.sh
    elif [ -e /mnt/certs/ca-root.crt ] || [ -e /mnt/certs/ca-root.key ]; then
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
