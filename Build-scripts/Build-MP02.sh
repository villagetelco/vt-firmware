#! /bin/bash

# Default is for your local git repo to live in ~/Git. If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO=Git}

# Build script for MP-02 devices

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
DIRVER="RC4"
VER="SECN Version 2.0 "$DIRVER

###########################

echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp ~/$GITREPO/vt-firmware/SECN-build/ .
cp -fp ~/$GITREPO/vt-firmware/Build-scripts/FactoryRestore.sh  .

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-MP02-"$DIRVER

###########################

# Set up build directory
echo "New build directory  ./bin/ar71xx/builds/build-"$DIR
mkdir ./bin/ar71xx/builds/build-$DIR

# Create md5sums file
touch ./bin/ar71xx/builds/build-$DIR/md5sums

##########################

# Build function

function build_mp02() {

echo "Set up .config for "$1$2
rm ./.config
cp ./SECN-build/$1/config-$1$2  ./.config
echo "Run defconfig"
make defconfig > /dev/null

# Set target string
TARGET="$1"

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
make -j8
echo ""

echo  "Move files to build folder"
mv ./bin/ar71xx/openwrt*kernel.bin     ./bin/ar71xx/builds/build-$DIR/openwrt-$1$2-$DIRVER-kernel.bin
mv ./bin/ar71xx/openwrt*squashfs.bin   ./bin/ar71xx/builds/build-$DIR/openwrt-$1$2-$DIRVER-rootfs-squashfs.bin
mv ./bin/ar71xx/openwrt*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR/openwrt-$1$2-$DIRVER-squashfs-sysupgrade.bin

echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo ""

echo "Update md5sums"
cat ./bin/ar71xx/md5sums | sed s/dragino2/MP02-$DIRVER/ > ./bin/ar71xx/md5sums-MP02
cat ./bin/ar71xx/md5sums-MP02 | grep "MP02"    | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums

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

build_mp02 MP02 
build_mp02 MP02 -Ast
build_mp02 MP02 -CC
build_mp02 MP02 -NDS
build_mp02 MP02 -Pol

echo " "
echo " Build script MP02 complete"
echo " "
echo '----------------------------'

exit

