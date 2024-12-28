#!/bin/bash
source /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf
PACKAGE=$1
PREFIX=$PACKAGE
curl -qsL "https://sourceforge.net/projects/freetype/best_release.json" | sed "s/, /,\n/g" | grep filename | grep tar | head -1 | sed 's|.*/||g' | sed 's/".*//g' | sed 's/.tar.*//' | sed 's/freetype-//' 

