#!/bin/bash
source ../autobuild.conf
REPO="fltk/fltk"
LATEST_VER=$(curl -Ls \
 -H "Accept: application/vnd.github+json" \
 -H "Authorization: Bearer $GITHUB_API_KEY "\
 -H "X-GitHub-Api-Version: 2022-11-28" \
 https://api.github.com/repos/$REPO/tags | grep name | head -1 | sed 's/.$//' | sed 's/\"//g' | sed 's/.*://' | sed 's/^.//' | sed 's/.*-//g' | sed 's/v//')
echo $LATEST_VER
