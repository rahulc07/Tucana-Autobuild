#!/bin/bash
source /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf
PACKAGE=$1
curl -qsL "https://sourceforge.net/projects/$PACKAGE/best_release.json" | sed "s/, /,\n/g" | sed -rn "/release/,/\}/{ /filename/{ 0,//s/([^0-9]*)([0-9\.]+)([^0-9]*.*)/\2/ p }}"

