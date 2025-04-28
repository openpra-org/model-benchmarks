#!/usr/bin/env bash

set -a

sudo touch /opt/ftrex/FTREX.key
sudo chmod 0666 /opt/ftrex/FTREX.key
cat /run/secrets/ftrex-key > /opt/ftrex/FTREX.key
ftrex "/SERIAL=$(cat /run/secrets/ftrex-serial)"

# If there are additional arguments, run them in a new bash shell
if [ $# -gt 0 ]; then
    /bin/bash -c "$*"
else
    echo "No additional commands to execute."
fi