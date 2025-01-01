#!/bin/bash
source autobuild.conf
SCRIPTS_PATH=$SCRAPER_LOCATIONS/
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')
URL=https://download.gnome.org/sources/$PACKAGE_PREFIX

curl -Ls https://download.gnome.org/sources/$PACKAGE_PREFIX/cache.json | jq -r ".[1].$PACKAGE_PREFIX | to_entries | .[].key" | grep -v "alpha" | grep -v "beta" | sort -rV | head -1
