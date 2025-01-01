#!/bin/bash
source autobuild.conf
SCRIPTS_PATH=$SCRAPER_LOCATIONS/
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')
URL=https://download.gnome.org/sources/$PACKAGE_PREFIX

if [[ $GNOME_DE == 1 ]]; then
    VERSIONS_REPEAT=$(python3 $SCRIPTS_PATH/gnome-scrape-DE.py $URL | grep $PACKAGE_PREFIX- | sed 's/.*-//g' | sed 's/.[a-z].*//g')
else
    VERSIONS_REPEAT=$(python3 $SCRIPTS_PATH/gnome-scrape.py $URL | grep $PACKAGE_PREFIX- | sed 's/.*-//g' | sed 's/.[a-z].*//g')
fi

VERSIONS=$(awk 'BEGIN{RS=ORS="\n"}!a[$0]++' <<< $VERSIONS_REPEAT)

echo $VERSIONS | sed 's/\ /\n/g' | sort -rV | head -1

