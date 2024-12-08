#!/bin/bash
source /home/rahul/Git-Clones/autobuilds/12-07-2024/autobuild.conf
PACKAGE=$1
cd $BUILD_SCRIPTS_ROOT
REPO="sqlite/sqlite"
LATEST_VER=$(curl -Ls \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_API_KEY "\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/tags | grep name | grep -o -E "[0-9]+\.[0-9]+\.[0-9]+" | sort -r | head -1 | sed -e 's/\./\n/' -e 's/\./0/' -e 's/$/00/')

echo $LATEST_VER | sed 's/\ //'
