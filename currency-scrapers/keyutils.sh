#!/bin/bash
source autobuild.conf
URL=http://deb.debian.org/debian/pool/main/k/keyutils/
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')

VERSIONS_REPEAT=$(python3 $SCRAPER_LOCATIONS/classic-scrape.py $URL | grep '\.orig' ) 
VERSIONS=$(awk 'BEGIN{RS=ORS="\n"}!a[$0]++' <<< $VERSIONS_REPEAT)
echo $VERSIONS | sed 's/\ /\n/g' | sed 's/\.orig.*//g' | sed 's/[[:alpha:]]//g' | sort -rV |  head -1  | sed 's/-//' | sed 's/\_//'

