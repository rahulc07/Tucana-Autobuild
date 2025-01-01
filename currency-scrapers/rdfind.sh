#!/bin/bash
source autobuild.conf
PACKAGE=$1
cd $BUILD_SCRIPTS_ROOT
REPO=pauldreik/rdfind
LATEST_VER=$(curl -Ls \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_API_KEY "\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/releases/latest | grep tag_name | sed 's/.$//' | sed 's/\"//g' | sed 's/.*://' | sed 's/^.//' | sed 's/.*-//g' | sed 's/v//')
# Some apps have TAG_OVERRIDE because the tags are newer than the releases, in that case use those instead
cat $(find . -name $PACKAGE -not -path './.git*') | grep TAG_OVERRIDE &> /dev/null
if [[ $? == 0 ]]; then
   LATEST_VER=""
fi


if [[ -z $LATEST_VER ]]; then
  LATEST_VER=$(curl -Ls \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_API_KEY "\
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$REPO/tags | grep name | head -1 | sed 's/.$//' | sed 's/\"//g' | sed 's/.*://' | sed 's/^.//' | sed 's/.*-//g' | sed 's/v//')
fi
echo $LATEST_VER | sed 's|releases/||g'
