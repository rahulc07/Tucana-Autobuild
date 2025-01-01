#!/bin/bash
source autobuild.conf

# Check whether a package is being held for any reason any remove it
# from the currency script
cd $BUILD_SCRIPTS_ROOT
cat $AUTOBUILD_ROOT/latest-ver.txt && cat $AUTOBUILD_ROOT/all-pkgver.txt | sed 's/:.*//g' | while IFS= read -r package; do
  cat $(find . -type f -not -path "./.git*" -name $package) | grep HOLD_TUCANA
  if [[ $? == 0 ]]; then
    sed -i "/^$package:.*/d" $AUTOBUILD_ROOT/latest-ver.txt
    sed -i "/^$package:.*/d" $AUTOBUILD_ROOT/all-pkgver.txt
  fi
done


