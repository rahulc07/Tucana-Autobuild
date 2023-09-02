#!/bin/bash
# This sets the location for the autobuild.conf
LOCATION=$(readlink -f autobuild.conf)
FILES=$(grep -r 'source autobuild.conf' | sed 's/:.*//g')
echo "$FILES" | while IFS= read -r file; do
   sed -i "s|autobuild\.conf|$LOCATION|g" $file
done
# Set Working directory
sed -i "s|ROOT\=PUTROOTHERE|ROOT=$(pwd)|" autobuild.conf

