#!/bin/bash
source autobuild.conf
URL=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL= | sed 's![^/]*$!!' | sed 's/URL=//g'| sed 's![^/]*$!!' )
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')

VERSIONS_REPEAT=$(python3 $SCRAPER_LOCATIONS/classic-scrape.py $URL | grep $PACKAGE_PREFIX- | sed 's/.*-//g' | sed 's/.[a-z].*//g')
VERSIONS=$(awk 'BEGIN{RS=ORS="\n"}!a[$0]++' <<< $VERSIONS_REPEAT)

echo $VERSIONS | sed -e 's/\ /\n/g'  -e 's/[[:alpha:]]//g' | grep -E '[0-9]\.[0-9][0,2,4,6,8].[0-9]+' | sort -rV | head -1


