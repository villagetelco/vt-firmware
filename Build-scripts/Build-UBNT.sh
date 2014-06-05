#! /bin/bash

# Default is for your local git repo to live in ~/Git. If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO=Git}

# Build script for UBNT devices

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
DIRVER="RC6"
VER="SECN-2_0-"$DIRVER

###########################

echo "Copy files from Git repo into build folder"
REPO=vt-firmware
rm -rf ./SECN-build/
cp -rp ~/$GITREPO/$REPO/SECN-build/ .
cp -fp ~/$GITREPO/$REPO/Build-scripts/FactoryRestore.sh  .

###########################

echo "Get source repo details"
BUILDPWD=`pwd`
cd  ~/$GITREPO/$REPO
REPOID=`git describe --long --dirty --abbrev=10 --tags`
cd $BUILDPWD

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-UBNT-"$DIRVER

###########################

# Set up build directory
echo "New build directory  ./bin/ar71xx/builds/build-"$DIR
mkdir ./bin/ar71xx/builds/build-$DIR

# Create md5sums files
echo $DIR > ./bin/ar71xx/builds/build-$DIR/md5sums
echo $DIR > ./bin/ar71xx/builds/build-$DIR/md5sums-$VER

##########################

# Build function

function build_ubnt() {

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

echo "Version: " $VER $TARGET $2
echo "Date stamp: " $DATE

echo "Version: " $VER  $TARGET $2  > ./files/etc/secn_version
echo "Build date " $DATE           >> ./files/etc/secn_version
echo "GitHub "$REPO $REPOID        >> ./files/etc/secn_version
echo " "                           >> ./files/etc/secn_version
echo ""

echo "Banner version info:"
cat ./files/etc/secn_version
echo ""
 
echo "Clean up any left over files"
rm ./bin/ar71xx/openwrt-*
echo ""

echo "Run make for "$1$2
make
echo ""

echo "Update original md5sums file"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""

echo  "Rename files to add version info"
for n in `ls ./bin/ar71xx/*.bin`; do mv  $n   ./bin/ar71xx/openwrt-$VER$2-`echo $n|cut -d '-' -f 5-10`; done
echo ""

echo "Update new md5sums file"
md5sum ./bin/ar71xx/*-squash*sysupgrade.bin >> ./bin/ar71xx/builds/build-$DIR/md5sums-$VER
#md5sum ./bin/ar71xx/*-squash*factory.bin    >> ./bin/ar71xx/builds/build-$DIR/md5sums-$VER

echo  "Move files to build folder"
mv ./bin/ar71xx/*-squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
#mv ./bin/ar71xx/*-squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo ""

echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
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

build_ubnt UBNT 

echo " "
echo " Build script UBNT complete"
echo " "
echo '----------------------------'

exit

