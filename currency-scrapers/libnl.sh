#!/bin/bash
source autobuild.conf
PACKAGE=$1
cd $BUILD_SCRIPTS_ROOT
cat $(find . -name $PACKAGE) | grep github &> /dev/null
if [[ $? -ne 0 ]]; then
   exit 1
fi
REPO=$(cat $(find . -name $PACKAGE) | grep URL | head -1 | sed 's/.*\.com//' | sed 's|/|!|3' | sed 's/!.*//' | sed 's/^.//')
LATEST_VER=$(curl -Ls \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer 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 "\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/releases/latest | grep tag_name | sed 's/.$//' | sed 's/\"//g' | sed 's/.*://' | sed 's/^.//' | sed 's/.*-//g' | sed 's/v//' | sed 's/libnl//g')
# Some apps have TAG_OVERRIDE because the tags are newer than the releases, in that case use those instead
cat $(find . -name $PACKAGE) | grep TAG_OVERRIDE &> /dev/null
if [[ $? == 0 ]]; then
   LATEST_VER=""
fi


if [[ -z $LATEST_VER ]]; then
  LATEST_VER=$(curl -Ls \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer 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 "\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/tags | grep name | head -1 | sed 's/.$//' | sed 's/\"//g' | sed 's/.*://' | sed 's/^.//' | sed 's/.*-//g' | sed 's/v//')
fi
echo $LATEST_VER
