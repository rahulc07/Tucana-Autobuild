#!/bin/bash
# This initalizes building packages based on the currency check output for the day

# Again, this is some of the worst yet most functional code I have ever written.  Please read everything twice before assuming that something doesn't work. 
# To use this script you have to change paths in 3 files, convert_txt_to_script.sh (run the build_new_currency function to make a new currency.sh), $BUILD_SCRIPTS_ROOT/scripts/generate_pkgvers.sh and this file to make the currency checks work.
source autobuild.conf
rm -rf $AUTOBUILD_ROOT
mkdir -p $AUTOBUILD_ROOT
build_new_currency() {
 cd $CURRENCY_TXT_LOCATIONS
 find . -type f | while IFS= read -r txt; do
  bash $AUTOMATION_SCRIPTS/convert_txt_to_script.sh  $txt
 done
}
email_upgrades() {

cd $AUTOBUILD_ROOT

# Make the file to email
echo "From: Tucana Autobuild Tool
Subject: Tucana Build Manifest for $(date '+%B %d %Y')
Tucana Currency Check for $(date '+%B %d %Y')
Packages that are going to be built:
Package name: (Version in repo)   (Version going to be built)

" > $AUTOBUILD_ROOT/email_upgrades.txt 


for PACKAGE in $UPGRADE_PACKAGES; do
  echo "$PACKAGE: $(cat $AUTOBUILD_ROOT/all-pkgver.txt | grep -E "^$PACKAGE:" | sed 's/.*://g') $(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*://')" >> $AUTOBUILD_ROOT/email_upgrades.txt
done

# Email the file (do this your own way this script will NOT be released)
/home/rahul/lfs/email_from_tucana.sh email_upgrades.txt

}

notify_failed_package() {
cd $AUTOBUILD_ROOT
# Error code 1 = General Build Failure
# Error Code 2 = Currency Check Failure
local code=$2
local package=$1
if [[ $code == 2 ]]; then
  email_string="due to a currency check failure"
else
  email_string="due to a build failure, logs can be found at $LOG_ROOT"
fi
echo "From: Tucana Auto Build Tool
Subject: Tucana build failure $package $(date '+%m-%d-%Y') 
Tucana Autobuild System
The package $package failed to build $email_string

---
TAS " > failed_$package.txt

# Email
echo "Emailing Results"
/home/rahul/lfs/email_from_tucana.sh failed_$package.txt
}
chroot_setup() {


  if [[ -d $CHROOT/dev ]]; then
     umount $CHROOT/dev/pts
     umount $CHROOT/dev
     umount $CHROOT/proc
     umount $CHROOT/sys
     rm -rf $CHROOT
  fi
  sleep 3  
  # Subset of the installer script, check there for explanations
  cd $AUTOBUILD_ROOT
  git clone https://github.com/xXTeraXx/Tucana.git
  # Change Install path and Repo
  sed -i "s|INSTALL_PATH=.*|INSTALL_PATH=$CHROOT|g" Tucana/mercury/mercury-install
  sed -i "s|INSTALL_PATH=.*|INSTALL_PATH=$CHROOT|g" Tucana/mercury/mercury-sync
  sed -i "s|REPO=.*|REPO=$REPO|g" Tucana/mercury/mercury-install
  sed -i "s|REPO=.*|REPO=$REPO|g" Tucana/mercury/mercury-sync
  
  # Install the base system
  cd Tucana/mercury
  ./mercury-sync
  printf "y\n" | ./mercury-install base
  
  # Mount temp filesystems
  mount --bind /dev $CHROOT/dev
  mount --bind /proc $CHROOT/proc
  mount --bind /sys $CHROOT/sys
  mount --bind /dev/pts $CHROOT/dev/pts

  # Setup Systemd services (probably not needed)
  chroot $CHROOT /bin/bash -c "systemd-machine-id-setup && systemctl preset-all"
  
  # SSL and shadow first time setup
   # DNS
  echo "nameserver 1.1.1.1" > $CHROOT/etc/resolv.conf
  chroot $CHROOT /bin/bash -c "make-ca -g --force"
  chroot $CHROOT /bin/bash -c "pwconv"
  
  # Kernel & Build Essentials (steam is the easiest way to get the lib32 stuff)
  chroot $CHROOT /bin/bash -c "printf 'y\n' | mercury-install linux-tucana mpc gcc binutils steam automake autoconf ninja meson cmake make flex bison gawk gperf pkgconf file patch gettext perl texinfo less check m4 bc glslang vulkan-headers git gobject-introspection gi-docgen pyproject-hooks python-build python-installer groff"
  
  # Locale
  echo "Building Locales"
  chroot $CHROOT /bin/bash -c "mkdir -pv /usr/lib/locale
   localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
   localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
   localedef -i de_DE -f ISO-8859-1 de_DE
   localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
   localedef -i de_DE -f UTF-8 de_DE.UTF-8
   localedef -i el_GR -f ISO-8859-7 el_GR
   localedef -i en_GB -f ISO-8859-1 en_GB
   localedef -i en_GB -f UTF-8 en_GB.UTF-8
   localedef -i en_HK -f ISO-8859-1 en_HK
   localedef -i en_PH -f ISO-8859-1 en_PH
   localedef -i en_US -f ISO-8859-1 en_US
   localedef -i en_US -f UTF-8 en_US.UTF-8
   localedef -i es_ES -f ISO-8859-15 es_ES@euro
   localedef -i es_MX -f ISO-8859-1 es_MX
   localedef -i fa_IR -f UTF-8 fa_IR
   localedef -i fr_FR -f ISO-8859-1 fr_FR
   localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
   localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
   localedef -i is_IS -f ISO-8859-1 is_IS
   localedef -i is_IS -f UTF-8 is_IS.UTF-8
   localedef -i it_IT -f ISO-8859-1 it_IT
   localedef -i it_IT -f ISO-8859-15 it_IT@euro
   localedef -i it_IT -f UTF-8 it_IT.UTF-8
   localedef -i ja_JP -f EUC-JP ja_JP
   localedef -i ja_JP -f SHIFT_JIS ja_JP.SJIS 2> /dev/null || true
   localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
   localedef -i nl_NL@euro -f ISO-8859-15 nl_NL@euro
   localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
   localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
   localedef -i se_NO -f UTF-8 se_NO.UTF-8
   localedef -i ta_IN -f UTF-8 ta_IN.UTF-8
   localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
   localedef -i zh_CN -f GB18030 zh_CN.GB18030
   localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
   localedef -i zh_TW -f UTF-8 zh_TW.UTF-8"


   # Copy the build scripts 
   cp  -r $BUILD_SCRIPTS_ROOT $CHROOT/Tucana-Build-Scripts

   # Make usr/src for kernel builds
   mkdir -p $CHROOT/usr/src

}
install_make_depends() {
  local PACKAGE=$1
  sudo chroot $CHROOT /bin/bash -c "printf 'y' | mercury-install $PACKAGE"
  cat $(find . -type f -name $PACKAGE -print | cut -d/ -f2-) | grep make-depends | grep -E -o '".*"' | sed 's/"//g' &> /dev/null
  if [[ $? == 0 ]]; then
     local DEPENDS=$(cat $(find . -type f -name $PACKAGE -print | cut -d/ -f2-) | grep make-depends | grep -E -o '".*"' | sed 's/"//g')
     echo $DEPENDS |  grep -E "[[:alpha:]]" 
     if [[ $? == 0 ]]; then
       sudo chroot $CHROOT /bin/bash -c "printf 'y' | mercury-install $DEPENDS"
     else 
       echo "No make depends found" 
     fi 
   fi   
}

order() {
  local package=$1
  cat $ROOT/full-tree-depend/$package-full-tree.txt > /dev/null
  # Sanity check to make sure that the file exists
  if [[ ! $? == 0 ]]; then
     echo "WARNING: FULL TREE DEPENDS FILE NOT FOUND FOR $package"
     echo "WARNING: FULL TREE DEPENDS FILE NOT FOUND FOR $package" > $LOG_ROOT/logs/depend-tree-$package.txt
  fi

  DEPENDS=$(cat $ROOT/full-tree-depend/$package-full-tree.txt)
  # Loop through the depends, check to see whether it is in the current list of upgrade packages, if it is remove it from the list and add it back at the beginning so it goes first.
  for depend in $DEPENDS; do
     echo "$UPGRADE_PACKAGES" | grep -E -x "$depend" > /dev/null
     if [[ $? == 0 ]]; then
        # Remove
        UPGRADE_PACKAGES_TEMP="$(echo "$UPGRADE_PACKAGES_TEMP" | sed "/$depend/d")"
        # Move it to the beginning
        UPGRADE_PACKAGES_TEMP1="$(echo "$UPGRADE_PACKAGES_TEMP" | sed "1i $depend")"
        UPGRADE_PACKAGES_TEMP="$UPGRADE_PACKAGES_TEMP1"
     fi
  done
}


# Generate the currency check script
echo "Generating Currency Check Script"
build_new_currency
# Run the currency check
echo "Running Currency"
cd $AUTOBUILD_ROOT
bash currency.sh
# Get the pkgvers in the Repo at that moment
cd $BUILD_SCRIPTS_ROOT
echo "Getting current package versions"
$AUTOMATION_SCRIPTS/generate_pkgvers.sh # The output variable in generate_pkgvers MUST point to the same folder as $AUTOBUILD_ROOT in this script

# Remove hold packages
$AUTOMATION_SCRIPTS/hold.sh


# Sort the currency output
cd $AUTOBUILD_ROOT
cat latest-ver.txt | sort > latest-ver-sorted.txt
# Diff the 2 to find new versions
NEW_VERSIONS=$(diff latest-ver-sorted.txt all-pkgver.txt | grep '<' | sed 's/<\ //g')
UPGRADE_PACKAGES=$(echo "$NEW_VERSIONS" | sed 's/:.*//')
# Quick check to see if there are updates
if [[ $UPGRADE_PACKAGES == "" ]]; then
   echo "No updates found"
   exit 0
fi

# Make the email list
# Emailing outline of updates
email_upgrades

# Store the upgrade packages just in case this script crashes 
echo "$UPGRADE_PACKAGES" > $AUTOBUILD_ROOT/too-upgrade.tmp
echo "Changing versions"
# Change the versions within the build scripts
cd $BUILD_SCRIPTS_ROOT


# Both of these have highly predictable input and will NEVER contain special characters or spaces don't @ me for not using a while loop here, using a for loop makes the code for readable and faster. 
for PACKAGE in $UPGRADE_PACKAGES; do
  echo "Changing $PACKAGE PKG_VER"
  cd $BUILD_SCRIPTS_ROOT
  LOCATION=$(find . -type f -name $PACKAGE)
  # Quick sanity check to make sure that the currency script didn't fail
  echo "$NEW_VERSIONS" | grep $PACKAGE | grep -E ': .*[0-9]+' &> /dev/null
  if [[ $? -ne 0 ]]; then
     echo "Currency check on $PACKAGE FAILED! Removing from upgrade list"
     UPGRADE_PACKAGES1=$(echo "$UPGRADE_PACKAGES" | sed "/$PACKAGE/d")
     UPGRADE_PACKAGES="$UPGRADE_PACKAGES1"
     notify_failed_package "$PACKAGE" "2"
  else
     echo "$PACKAGE passed currency checks"
     sed -i "s/PKG_VER=.*/PKG_VER=$(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*:\ //')/g" $LOCATION
     # Run a git commit to make versioning easier
     git commit -am "Update $PACKAGE to $(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*:\ //')"
     # Lib32 check
     #if [[ $(cat $CURRENCY_TXT_LOCATIONS/lib32-match.txt) | grep $PACKAGE ]]; then
     #  echo "Lib32 match found for $PACKAGE"
       # Add lib32 package to the upgrade list
       # UPGRADE_PACKAGES="$UPGRADE_PACKAGES lib32-$PACKAGE"
       # change the pkgver in the lib32 packages
       #sed -i "s/PKG_VER=.*/PKG_VER=$(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*:\ //')/g" $(find . -name lib32-$PACKAGE)
     #fi
       
  fi
done


# Set the build order
# Initalize the UPGRADE_PACKAGES_TEMP variable
UPGRADE_PACKAGES_TEMP="$UPGRADE_PACKAGES"
for PACKAGE in $UPGRADE_PACKAGES; do
   order "$PACKAGE"
done
# Reset Var
UPGRADE_PACKAGES="$UPGRADE_PACKAGES_TEMP"

echo "Preparing for build"
echo "Creating Chroot"
chroot_setup
# Prepare to do the final build (assuming host system is clean)
cd $BUILD_SCRIPTS_ROOT
mkdir -p $CHROOT/finished $CHROOT/pkgs $CHROOT/blfs/builds/
rm -rf /blfs/builds/* /pkgs/*
mkdir -p $LOG_ROOT

# Build the updates
for PACKAGE in $UPGRADE_PACKAGES; do 
   cd $BUILD_SCRIPTS_ROOT
   LOCATION=$(find . -type f -name $PACKAGE -print | cut -d/ -f2-)
   echo "Building $PACKAGE"
   chroot $CHROOT /bin/bash -c "printf 'y' | mercury-install $PACKAGE"
   echo "Installing Depends"
   install_make_depends "$PACKAGE"
   chroot $CHROOT /bin/bash -c "bash -e /Tucana-Build-Scripts/$LOCATION" &> $LOG_ROOT/$PACKAGE-$(date '+%m-%d-%Y').log
   if [[ $? -ne 0 ]]; then
     notify_failed_package "$PACKAGE" "1"
     PACKAGE_COMMIT=$(git log --grep="Update $PACKAGE to $(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*:\ //')" | grep commit | sed 's/commit\ //g')
     git revert --no-commit $PACKAGE_COMMIT
     git commit -am "Failed Update $PACKAGE"
     sleep 2
   else
     SUCCESSFUL_PACKAGES="$SUCCESSFUL_PACKAGES $PACKAGE"
   fi
done

echo $SUCCESSFUL_PACKAGES
