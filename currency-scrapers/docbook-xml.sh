#!/bin/bash
source autobuild.conf
SCRIPTS_PATH=$SCRAPER_LOCATIONS/
URL=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL= | sed 's![^/]*$!!' | sed 's/URL=//g' | sed 's/.$//' | sed 's![^/]*$!!' )
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')
LATEST_FOLDER=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py $URL | grep [0-9] | grep '\.' | grep -E -o -x "[0-9]+\.[0-9]/" | sort -rV | head -1)
echo "5.0"
LATEST_VERSION=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py "$URL/$LATEST_FOLDER" | grep zip | sed 's/.*-//g' | sed 's/.[a-z].*//g' |  sed 's/\ /\n/g' | sed 's/[[:alpha:]]//g' | sort -rV | head -1 )
echo "4.5"

