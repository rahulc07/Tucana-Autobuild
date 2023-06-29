#!/bin/bash
source autobuild.conf
SCRIPTS_PATH=$SCRAPER_LOCATIONS/
URL=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL= | sed 's![^/]*$!!' | sed 's/URL=//g' | sed 's/.$//' | sed 's![^/]*$!!' | sed 's/.$//' | sed 's![^/]*$!!' )
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')
LATEST_FOLDER=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py $URL | grep [0-9] | grep '\.' | sort -rV | head -1)
LATEST_VERSION=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py "$URL/$LATEST_FOLDER/source/" | grep tar |  grep -o -E "[0-9]+_[0-9]+_[0-9]+" | sort -rV | head -1 )
echo $LATEST_VERSION


