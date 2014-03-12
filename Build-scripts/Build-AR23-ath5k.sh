#! /bin/bash

# Default is for your local git repo to live in ~/Git. If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO=Git}

# Build script for AR23xx devices

echo ""

# Check to see if setup has already run
if [ ! -f ./already_configured ]; then 
  # make sure it only executes once
  touch ./already_configured  
  echo " Make builds directory"
  mkdir ./bin/
  mkdir ./bin/ar71xx/
  mkdir ./bin/ar71xx/builds
  mkdir ./bin/atheros/
  mkdir ./bin/atheros/builds
  echo " Initial set up completed. Continuing with build"
  echo ""
else
  echo "Build environment is configured. Continuing with build"
  echo ""
fi

#########################

echo "Start build process"

# Set up version strings
VER="Version 2.0 RC4-Ath5k"
DIRVER="RC4-Ath5k"

###########################

echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp ~/$GITREPO/vt-firmware/SECN-build/ .
cp -fp ~/$GITREPO/vt-firmware/Build-scripts/FactoryRestore.sh  .

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-AR23-"$DIRVER

###########################

# Set up build directory
echo "Set up new build directory  ./bin/atheros/builds/build-"$DIR
mkdir ./bin/atheros/builds/build-$DIR

# Create md5sums file
touch ./bin/atheros/builds/build-$DIR/md5sums

###########################

echo '----------------------------'

echo "Set up .config for Ubiquity AR23 ath5k"
rm ./.config
cp ./SECN-build/AR23/config-AR23-ath5k  ./.config
echo " Run defconfig"
make defconfig > /dev/null

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for AR23 ath5k"
echo "Remove files directory"
rm -r ./files
echo "Copy generic files"
cp -r ./SECN-build/files             .   
echo "Overlay device specific files"
cp -r ./SECN-build/AR23/files        .    
echo "Overlay driver specific files"
cp -r ./SECN-build/AR23/ath5k/files  .   

echo "Build Factory Restore tar file"
./FactoryRestore.sh	

echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $TARGET
echo $VER  $TARGET               > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version
 
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for AR23 ath5k"
make

echo  "Move files to build folder"
mv ./bin/atheros/*squash*    ./bin/atheros/builds/build-$DIR
mv ./bin/atheros/*.lzma      ./bin/atheros/builds/build-$DIR

echo "Update md5sums"
cat ./bin/atheros/md5sums | grep "squashfs" >> ./bin/atheros/builds/build-$DIR/md5sums
cat ./bin/atheros/md5sums | grep "lzma"     >> ./bin/atheros/builds/build-$DIR/md5sums

echo "Clean up unused files"
rm ./bin/atheros/openwrt-*

echo ""
echo "End Ubiquity-AR231x ath5k build"
echo ""

exit


