#!/bin/bash
source autobuild.conf
URL=$(cat $(find $BUILD_SCRIPTS_ROOT/ -name $1) | grep URL= | sed 's![^/]*$!!' | sed 's/URL=//g'| sed 's![^/]*$!!' )
PACKAGE_PREFIX=aspell
VERSIONS=$(python3 $SCRAPER_LOCATIONS/classic-scrape.py $URL)

echo "$VERSIONS" | sed -e '/lang/d' -e '/sig/d' | grep -E  'aspell-.*.tar.gz'  | sed -e 's/aspell-//g' -e 's/\.tar\.gz//g' | sort -rV | head -n1


