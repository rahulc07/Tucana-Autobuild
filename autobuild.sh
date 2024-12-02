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
echo "From: Tucana Autobuild Tool <autobuild@tucanalinux.org>
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
  echo "en_US.UTF-8 UTF-8" > $CHROOT/etc/locale.gen
  chroot $CHROOT /bin/bash -c "locale-gen"


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
     if [[ $(cat $ROOT/lib32-match.txt | grep lib32-$PACKAGE) ]]; then
       echo "Lib32 match found for $PACKAGE"
       # To make sure that the build order is correct, these are NOT put into UPGRADE_PACKAGES, 
       # They are instead just done dynamically
       LOCATION=$(find . -type f -name lib32-$PACKAGE)
       sed -i "s/PKG_VER=.*/PKG_VER=$(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*:\ //')/g" $LOCATION
       git commit -am "Update lib32-$PACKAGE to $(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*:\ //')"
     fi
       
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
     PACKAGE_COMMIT=$(git log --grep="Update $PACKAGE to $(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*: //')" --format="%H" -n 1)
     git revert --no-commit $PACKAGE_COMMIT
     git commit -am "Failed Update $PACKAGE"
     sleep 2
   else
     SUCCESSFUL_PACKAGES="$SUCCESSFUL_PACKAGES $PACKAGE"
   fi


   # Lib32
   if [[ $(cat $ROOT/lib32-match.txt | grep lib32-$PACKAGE) ]]; then
     cd $BUILD_SCRIPTS_ROOT
     LOCATION=$(find . -type f -name lib32-$PACKAGE -print | cut -d/ -f2-)
     echo "Building $PACKAGE"
     chroot $CHROOT /bin/bash -c "printf 'y' | mercury-install lib32-$PACKAGE"
     echo "Installing Depends"
     install_make_depends "lib32-$PACKAGE"
     chroot $CHROOT /bin/bash -c "bash -e /Tucana-Build-Scripts/$LOCATION" &> $LOG_ROOT/lib32-$PACKAGE-$(date '+%m-%d-%Y').log
     if [[ $? -ne 0 ]]; then
       notify_failed_package "lib32-$PACKAGE" "1"
     PACKAGE_COMMIT=$(git log --grep="Update lib32-$PACKAGE to $(echo "$NEW_VERSIONS" | grep -E "^$PACKAGE:" | sed 's/.*: //')" --format="%H" -n 1)
       git revert --no-commit $PACKAGE_COMMIT
       git commit -am "Failed Update $PACKAGE"
       sleep 2
     else
       SUCCESSFUL_PACKAGES="$SUCCESSFUL_PACKAGES lib32-$PACKAGE"
     fi
   fi 
done

echo $SUCCESSFUL_PACKAGES
