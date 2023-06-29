#!/bin/bash
source autobuild.conf
SCRIPTS_PATH=$SCRAPER_LOCATIONS/
URL=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL= | sed 's![^/]*$!!' | sed 's/URL=//g' | sed 's/.$//' | sed 's![^/]*$!!' )
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')
LATEST_FOLDER=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py $URL | grep [0-9] | grep '\.' | grep '/' | sed 's/dhcp-//g'| sort -rV | head -1)

LATEST_FOLDER_CHECK=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py $URL | grep [0-9] | grep '\.' | grep '/' | sed 's/dhcp-//g'| sort -rV | head -2)
if [[  $LATEST_FOLDER_CHECK == *$LATEST_FOLDER* ]]; then
   LATEST_FOLDER=$(echo $LATEST_FOLDER_CHECK | sed "s|$LATEST_FOLDER\ ||g")
fi
LATEST_VERSION=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py "$URL/$LATEST_FOLDER" | grep tar |  grep $PACKAGE_PREFIX | sed "s/.tar.*//g" | sed "s/.*dhcp-//" | sort -rV | head -1) 
echo $LATEST_VERSION


