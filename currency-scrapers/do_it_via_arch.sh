#!/bin/bash
source /home/rahul/Git-Clones/autobuilds/12-26-2024/autobuild.conf

# this is the last resort, or when I am too stupid to come up with the seds
# just get the package release from arch, it is probably new enough...


PACKAGE=$1
PACKAGE_LOCATION=$(find $BUILD_SCRIPTS_ROOT -name $PACKAGE)
# This script relies on there being an Arch eq. package listed in the 
# build-script itself.  Prefixed with ARCH_PKG= and ARCH_VAR= in a comment 
# Credit to all the volunteers please don't sue me


ARCH_PKG=$(cat $PACKAGE_LOCATION | grep ARCH_PKG= | sed 's/\#ARCH_PKG=//')
# What variable is the pkgver in
ARCH_VAR=$(cat $PACKAGE_LOCATION | grep ARCH_VAR= | sed 's/\#ARCH_VAR=//')
wget -q https://gitlab.archlinux.org/archlinux/packaging/packages/$ARCH_PKG/-/raw/main/PKGBUILD

PKG_VER=$(cat PKGBUILD | grep "$ARCH_VAR=" | sed "s/$ARCH_VAR=//")
echo $PKG_VER



rm PKGBUILD



