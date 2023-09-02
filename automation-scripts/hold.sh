#!/bin/bash
source autobuild.conf

# Check whether a package is being held for any reason any remove it
# from the currency script
cd $BUILD_SCRIPTS_ROOT
cat $CURRENCY_TXT_LOCATIONS/* | sed 's/:.*//g' | while IFS= read -r package; do
  cat $(find . $package) | grep HOLD_TUCANA
  if [[ $? == 0 ]]; then
    sed -i "s/^$package:.*//" $AUTOBUILD_ROOT/latest_ver.txt
    sed -i "s/^$package:.*//" $AUTOBUILD_ROOT/all-pkgver.txt
  fi
done

