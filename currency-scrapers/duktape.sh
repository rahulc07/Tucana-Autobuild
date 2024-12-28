#!/bin/bash
source /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf
URL=https://duktape.org/download.html
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')

VERSIONS_REPEAT=$(python3 $SCRAPER_LOCATIONS/classic-scrape.py $URL | grep $PACKAGE_PREFIX- | sed 's/.*-//g' | sed 's/.[a-z].*//g')
VERSIONS=$(awk 'BEGIN{RS=ORS="\n"}!a[$0]++' <<< $VERSIONS_REPEAT)

echo $VERSIONS | sed 's/\ /\n/g'  | sed 's/[[:alpha:]]//g' | sort -rV | head -1


