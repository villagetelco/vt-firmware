#! /bin/bash

# Default is for your local git repo to live in ../../Git
# If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO="../Git"}

# Select the repo to use
REPO="vt-firmware"


echo "************************************"
echo ""
echo "Build script for MP-01 device"

echo "Git directory: "$GITREPO
echo "Repo: "$REPO
echo " "

if [ ! -d $GITREPO"/"$REPO ]; then
	echo "Repo does not exist. Exiting build process"
	echo " "
	exit
fi

##############################

# Check to see if setup has already run
if [ ! -f ./already_configured ]; then 
  # make sure it only executes once
  touch ./already_configured  
  echo "Make builds directory"
  mkdir ./bin/
  mkdir ./bin/atheros/
  mkdir ./bin/atheros/builds
  echo " Backup original ./files directory"
  mv    ./files ./files.orig
  touch ./files
  echo "Initial set up completed. Continuing with build"
  echo ""
else
  echo "Build environment is configured. Continuing with build"
  echo ""
fi

#########################

echo "Start build process"

echo "Set up version strings"
DIRVER="RC1"
VER="SECN-2_0-"$DIRVER

###########################
echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp $GITREPO/$REPO/SECN-build/ .
cp -fp $GITREPO/$REPO/Build-scripts/FactoryRestore.sh  .


###########################

BUILDPWD=`pwd`
cd  $GITREPO/$REPO
REPOID=`git describe --long --dirty --abbrev=10 --tags`
cd $BUILDPWD
echo "Source repo details: "$REPO $REPOID

###########################

# Set up new directory name with date and version
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-MP01-"$DIRVER

###########################
BINDIR="./bin/atheros"
# Set up build directory
echo "Set up new build directory  $BINDIR/builds/build-"$DIR
mkdir $BINDIR/builds/build-$DIR

# Create md5sums files
echo $DIR > $BINDIR/builds/build-$DIR/md5sums.txt
echo $DIR > $BINDIR/builds/build-$DIR/md5sums-$VER.txt

##########################

# Build function

function build_mp01() {

echo "Set up files for "$1 $2
echo "Remove files directory"
rm -r ./files

echo "Copy generic files"
cp -r ./SECN-build/files     .  

echo "Overlay device specific files"
cp -r ./SECN-build/$1/files  .  
echo ""

echo "Overlay additional package files"
cp -r ./SECN-build/$1/package  .  
echo ""

echo "Copy driver code from Git repo into build folder"
rm -rf ./drivers
cp -rp ./SECN-build/$1/drivers  .

echo "Build Factory Restore tar file"
./FactoryRestore.sh	 
echo ""

echo "Check files directory"
ls -al ./files  
echo ""

echo "Set up .config for "$1 $2
rm ./.config

if [ $2 ]; then
	echo "Config file: config-"$1-$2
	cp ./SECN-build/$1/config-$1-$2  ./.config
else
	echo "Config file: config-"$1
	cp ./SECN-build/$1/config-$1  ./.config
fi

echo "Run defconfig"
make defconfig > /dev/null
echo ""

# Set up target display strings
TARGET=MP01
OPENWRTVER=`cat ./.config | grep "OpenWrt version" | cut -d : -f 2`

echo "Check .config version"
echo "Target:  " $TARGET
echo "OpenWRT: " $OPENWRTVER
echo ""

echo "Version: " $VER $TARGET $2
echo "Date stamp: " $DATE

echo "Version:    " $VER $TARGET $2       > ./files/etc/secn_version
#echo "OpenWRT:    " $OPENWRTVER           >> ./files/etc/secn_version
echo "Build date: " $DATE                 >> ./files/etc/secn_version
echo "GitHub:     " $REPO $REPOID         >> ./files/etc/secn_version
echo " "                                  >> ./files/etc/secn_version
echo ""

echo "Banner version info:"
cat ./files/etc/secn_version
echo ""

echo "Clean up any left over files"
rm $BINDIR/openwrt-*
echo ""

echo '----------------------------'
echo "Make MP channel driver"
cd ./drivers/asterisk
make
echo "Copy files"
cp ./gentone       ../../files/usr/lib/asterisk/modules
cp ./chan_mp.so    ../../files/usr/lib/asterisk/modules
cd ../..

echo '----------------------------'
echo "Make 8250 driver"
cd ./drivers/driver
make
echo "Copy files"
cp ./8250mp.ko   ../../files/lib/modules/*
cp ./mp.ko       ../../files/lib/modules/*
cd ../..

echo '----------------------------'


echo "Run make for "$1 $2
make
echo ""

echo "Update original md5sums file"
cat $BINDIR/md5sums | grep "openwrt"  >> $BINDIR/builds/build-$DIR/md5sums.txt
echo ""

echo "Update new md5sums file"
md5sum $BINDIR/*root.squashfs >> $BINDIR/builds/build-$DIR/md5sums-$VER.txt
md5sum $BINDIR/*.lzma         >> $BINDIR/builds/build-$DIR/md5sums-$VER.txt

echo  "Move files to build folder"
mv $BINDIR/*root.squashfs  $BINDIR/builds/build-$DIR
mv $BINDIR/*.lzma          $BINDIR/builds/build-$DIR

echo "Clean up unused files"
rm $BINDIR/openwrt-*
echo ""

echo ""
echo "End "$1 $2" build"
echo ""
echo '----------------------------'
}

############################


echo '----------------------------'
echo " "
echo "Start Device builds"
echo " "
echo '----------------------------'

build_mp01 MP01

echo " "
echo "Build script MP01 complete"
echo " "
echo '----------------------------'

exit

