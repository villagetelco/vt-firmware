#! /bin/sh

# Build script for MP-02 devices

echo ""

# Check to see if setup script has already run
if [ ! -f ./already_configured ]; then 
  echo "Build environment not configured. Quitting now"
  exit
else
  echo "Build environment is configured. Continuing with build"
  echo ""
fi

#########################

echo "Start build process"

# Set up version strings
VER="OLPC SECN Version 2.0 RC2"
DIRVER="RC2"

###########################

echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp ~/Git/vt-firmware/SECN-build/ .
echo "Overlay OLPC files"
cp -rp ~/Git/olpc/SECN-build/ .

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-OLPC-MP02-"$DIRVER

###########################

# Set up build directory
echo "New build directory  ./bin/ar71xx/builds/build-"$DIR
mkdir ./bin/ar71xx/builds/build-$DIR

# Create md5sums file
touch ./bin/ar71xx/builds/build-$DIR/md5sums

###########################

echo '----------------------------'

echo "Set up .config for MP-02"
rm ./.config
cp ./SECN-build/MP-02/.config  ./.config
echo " Run defconfig"
make defconfig > /dev/null

## Use for first build on a new revision to update .config file
#cp ./.config ./SECN-build/MP-02/.config 

## Get target device from .config file
##TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `
# Set target as MP-02
TARGET="MP-02"

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for MP-02 "
rm -r ./files

echo "Copy generic files"
cp -r ./SECN-build/files       .  

echo "Overlay device specific files"
cp -r ./SECN-build/MP-02/files .    

./FactoryRestore.sh			; echo "Build Factory Restore tar file"

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

echo "Run make for MP-02"
make -j8

echo  "Move files to build folder"
#mv ./bin/ar71xx/*-squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*dragino2*.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*u-boot.bin ./bin/ar71xx/builds/build-$DIR

echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
#cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
cat ./bin/ar71xx/md5sums | grep "dragino2" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
cat ./bin/ar71xx/md5sums | grep "u-boot"   | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End MP-02 build"
echo ""

##################

echo '----------------------------'

echo " Build script complete"; echo " "


