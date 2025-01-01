#!/bin/bash
source autobuild.conf
URL=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL= | sed 's![^/]*$!!' | sed 's/URL=//g'| sed 's![^/]*$!!' )
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')

VERSIONS_REPEAT=$(python3 $SCRAPER_LOCATIONS/classic-scrape.py $URL | grep $PACKAGE_PREFIX- | sed 's/.*-//g' | sed 's/.[a-z].*//g')
VERSIONS=$(awk 'BEGIN{RS=ORS="\n"}!a[$0]++' <<< $VERSIONS_REPEAT)
for VERSION in $VERSIONS; do
echo $VERSION | grep -o -E '\.[0-9]+\.' &> /dev/null
   if [[ $? == 0 ]] && [[ $(expr $(echo $VERSION | grep -o -E '\.[0-9]+\.' | sed 's/\.//g') % 2) -ne 0 ]]; then


      VERSIONS1=$(echo $VERSIONS | sed "s|$VERSION||g")
      VERSIONS=$VERSIONS1
   fi
done
echo $VERSIONS |  sed 's/\ /\n/g' | sort -rV | grep '\.' | head -1
