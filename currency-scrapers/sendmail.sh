#!/bin/bash
source /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf
URL=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL= | sed 's![^/]*$!!' | sed 's/URL=//g'| sed 's![^/]*$!!' )

PACKAGE_PREFIX=sendmail

VERSIONS_REPEAT=$(python3 $SCRAPER_LOCATIONS/classic-scrape.py $URL | grep 'tar\.gz' | grep "$PACKAGE_PREFIX\." | sed 's/sendmail\.//g')
VERSIONS=$(awk 'BEGIN{RS=ORS="\n"}!a[$0]++' <<< $VERSIONS_REPEAT)
echo $VERSIONS | sed 's/\ /\n/g'  | sed 's/[[:alpha:]]//g' | sort -rV | head -1 | sed 's/.$//' | sed 's/.$//'


