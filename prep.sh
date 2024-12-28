#!/bin/bash
# This sets the location for the /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf
LOCATION=$(readlink -f /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf)
FILES=$(grep -r 'source /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf' | sed 's/:.*//g')
echo "$FILES" | while IFS= read -r file; do
   sed -i "s|autobuild\.conf|$LOCATION|g" $file
done
# Set Working directory
sed -i "s|ROOT\=PUTROOTHERE|ROOT=$(pwd)|" /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf
sudo mercury-install --y jq

