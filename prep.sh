#!/bin/bash
# This sets the location for the autobuild.conf
LOCATION=$(readlink -f autobuild.conf)
FILES=$(grep -r 'source autobuild.conf' | sed 's/:.*//g')
echo "$FILES" | while IFS= read -r file; do
   sed -i "s|autobuild\.conf|$LOCATION|g" $file
done
# Set Working direcotry 
sed -i "s/ROOT=.*/ROOT=$(pwd)/" autobuild.conf

