#!/bin/bash
source autobuild.conf
OUTPUT=$AUTOBUILD_ROOT
# This gets the package versions currently in the repo
# Warning all of these are relative, you have to be in the build script root to run this properly
FILES=$(find . -maxdepth 1 -type f -not -path "./.git*" && find ./xorg -type f -not -path "./apps" && find ./base -type f && find ./i3 -type f && find  ./python-modules -type f  && find ./xfce4 -type f)
for file in $(echo $FILES | sort); do
  pkgver=$(cat $file | grep PKG_VER= | sed 's/PKG_VER=//g')
  package=$(echo $file | sed -r 's|(.*)/||')
  echo "$package: $pkgver" >> $OUTPUT/all-pkgver.txt
done 
cat $OUTPUT/all-pkgver.txt | sort > $OUTPUT/all-pkgver2.txt
mv $OUTPUT/all-pkgver2.txt $OUTPUT/all-pkgver.txt
