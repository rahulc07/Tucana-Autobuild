#!/bin/bash
source autobuild.conf
SCRIPTS_PATH=$SCRAPER_LOCATIONS/
URL=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL= | sed 's![^/]*$!!' | sed 's/URL=//g' | sed 's/.$//' | sed 's![^/]*$!!' )
PACKAGE_PREFIX=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL | head -1 | sed 's/URL=//g'| sed -r 's|(.*)/||'| sed 's|.tar.*||g' | sed 's|-[^-]*$||g')
FOLDERS=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py "$URL" | grep '[0-9]' | sed 's|/||' | sort -rV | sed 's/$/dd/')
for VERSION in $FOLDERS; do
 echo $VERSION | grep -o -E '\.[0-9]+' &> /dev/null
 if [[ $? == 0 ]] && [[ $(expr $(echo $VERSION | grep -o -E '\.[0-9]+' | sed 's/\.//g') % 2) -ne 0 ]]; then
       FOLDERS1=$(echo "$FOLDERS" | sed "s|$VERSION||")

       FOLDERS="$FOLDERS1"
 fi



done
LATEST_FOLDER=$(echo "$FOLDERS" | sed 's/dd//' | sort -rV | head -1)
LATEST_VERSION=$(python3 $SCRIPTS_PATH/classic-scrape-recursive.py "$URL/$LATEST_FOLDER" | grep tar |  grep $PACKAGE_PREFIX | sed 's/.*-//g' | sed 's/.[a-z].*//g' |  sed 's/\ /\n/g' | sed 's/[[:alpha:]]//g' | sort -rV | head -1 )
echo $LATEST_VERSION

