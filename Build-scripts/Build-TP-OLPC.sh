#! /bin/bash

# Default is for your local git repo to live in ~/Git. If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO=Git}

# Build script for TP Link devices
 
echo ""

# Check to see if setup has already run
if [ ! -f ./already_configured ]; then 
  # make sure it only executes once
  touch ./already_configured  
  echo "Make builds directory"
  mkdir ./bin/
  mkdir ./bin/ar71xx/
  mkdir ./bin/ar71xx/builds
  mkdir ./bin/atheros/
  mkdir ./bin/atheros/builds
  echo "Initial set up completed. Continuing with build"
  echo ""
else
  echo "Build environment is configured. Continuing with build"
  echo ""
fi


#########################

echo "Start build process"

echo "Set up version strings"
DIRVER="RC5"
VER="SECN Version 2.0 "$DIRVER

###########################

echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp ~/$GITREPO/vt-firmware/SECN-build/ .
cp -fp ~/$GITREPO/vt-firmware/Build-scripts/FactoryRestore.sh  .

echo "Overlay OLPC files"
cp -rp ~/$GITREPO/olpc/SECN-build/ .

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-TP-"$DIRVER

###########################

# Set up build directory
echo "New build directory  ./bin/ar71xx/builds/build-"$DIR
mkdir ./bin/ar71xx/builds/build-$DIR

# Create md5sums file
touch ./bin/ar71xx/builds/build-$DIR/md5sums

##########################

# Build function

function build_tp() {

echo "Set up .config for "$1$2
rm ./.config
cp ./SECN-build/$1/config-$1$2  ./.config
echo "Run defconfig"
make defconfig > /dev/null

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET
echo ""

echo "Set up files for "$1
echo "Remove files directory"
rm -r ./files

echo "Copy generic files"
cp -r ./SECN-build/files     .  

echo "Overlay device specific files"
cp -r ./SECN-build/$1/files  .  
echo ""

echo "Build Factory Restore tar file"
./FactoryRestore.sh	 
echo ""

echo "Check files directory"
ls -al ./files  
echo ""

echo "Version: "  $VER $TARGET
echo $VER  $TARGET               > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version
 
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Clean up any left over files"
rm ./bin/ar71xx/openwrt-*
echo ""

echo "Run make for "$1$2
make
echo ""

echo  "Move files to build folder"
mv ./bin/ar71xx/*-squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*-squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo ""

echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo ""

echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""

echo ""
echo "End "$1$2" build"
echo ""
echo '----------------------------'
}

############################


echo '----------------------------'
echo " "
echo "Start Device builds"
echo " "
echo '----------------------------'

build_tp WDR4300
build_tp WR842
build_tp MR3020
build_tp MR3420
build_tp WR703
build_tp WR741

echo " "
echo "Build script TP complete"
echo " "
echo '----------------------------'

exit

