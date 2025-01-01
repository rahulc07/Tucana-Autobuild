#!/bin/bash
source autobuild.conf
PACKAGE=$1
cd $BUILD_SCRIPTS_ROOT
REPO="xkbcommon/libxkbcommon"
LATEST_VER=$(curl -Ls \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_API_KEY "\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/releases/latest | grep tag_name | sed 's/.$//' | sed 's/\"//g' | sed 's/.*://' | sed 's/^.//' | sed 's/.*-//g' | sed 's/v//')
echo $LATEST_VER
