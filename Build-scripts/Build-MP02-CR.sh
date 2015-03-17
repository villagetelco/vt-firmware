#! /bin/bash

# Default is for your local git repo to live in ../../Git
# If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO="../../Git"}

# Select the repo to use
REPO="vt-firmware"


echo "************************************"
echo ""
echo "CR Build script for MP-02 CR device"

echo "Git directory: "$GITREPO
echo "Repo: "$REPO
echo " "

if [ ! -d $GITREPO"/"$REPO ]; then
	echo "Repo does not exist. Exiting build process"
	echo " "
	exit
fi

echo "Check out the correct branch"
BUILD_DIR=$(pwd)
cd $GITREPO"/"$REPO
git checkout secn_3.0 > /dev/null
git branch | grep "*"
cd $BUILD_DIR
pwd

##############################



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
DIRVER="BB-Alpha10"
VER="SECN-3_0-CR-"$DIRVER

###########################
echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp $GITREPO/$REPO/SECN-build/ .
cp -fp $GITREPO/$REPO/Build-scripts/FactoryRestore.sh  .

echo "Overlay Class Router files"
cp -rp $GITREPO/$REPO/CR-build/* ./SECN-build

###########################

BUILDPWD=`pwd`
cd  $GITREPO/$REPO
REPOID=`git describe --long --dirty --abbrev=10 --tags`
cd $BUILDPWD
echo "Source repo details: "$REPO $REPOID

###########################

# Set up new directory name with date and version
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-MP02-CR-"$DIRVER

###########################
BINDIR="./bin/ar71xx"
# Set up build directory
echo "Set up new build directory  $BINDIR/builds/build-"$DIR
mkdir $BINDIR/builds/build-$DIR

# Create md5sums files
echo $DIR > $BINDIR/builds/build-$DIR/md5sums
echo $DIR > $BINDIR/builds/build-$DIR/md5sums-$VER

##########################

# Build function

function build_mp02() {

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

# Set target string
TARGET=$1
OPENWRTVER=`cat ./.config | grep "OpenWrt version" | cut -d : -f 2`

echo "Check .config version"
echo "Target:  " $TARGET
echo "OpenWRT: " $OPENWRTVER
echo ""

echo "Set up files for "$1 $2
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

echo "Version:    " $VER $TARGET $2     > ./files/etc/secn_version
echo "OpenWRT:    " $OPENWRTVER           >> ./files/etc/secn_version
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

echo "Run make for "$1 $2
make -j8
echo ""

echo "Update original md5sums file"
cat $BINDIR/md5sums | grep "squashfs.bin"   | grep ".bin" >> $BINDIR/builds/build-$DIR/md5sums
cat $BINDIR/md5sums | grep "kernel.bin"     | grep ".bin" >> $BINDIR/builds/build-$DIR/md5sums
cat $BINDIR/md5sums | grep "sysupgrade.bin" | grep ".bin" >> $BINDIR/builds/build-$DIR/md5sums
echo ""

echo  "Rename files to add version info"
echo ""
if [ $2 ]; then
	for n in `ls $BINDIR/openwrt*.bin`; do mv  $n   $BINDIR/openwrt-$VER-$1-$2-`echo $n|cut -d '-' -f 5-10`; done
else
	for n in `ls $BINDIR/openwrt*.bin`; do mv  $n   $BINDIR/openwrt-$VER-$1-`echo $n|cut -d '-' -f 5-10`; done
fi

echo "Update new md5sums file"
md5sum $BINDIR/*-squash*sysupgrade.bin >> $BINDIR/builds/build-$DIR/md5sums-$VER
md5sum $BINDIR/openwrt*kernel.bin >>     $BINDIR/builds/build-$DIR/md5sums-$VER
md5sum $BINDIR/openwrt*squashfs.bin >>   $BINDIR/builds/build-$DIR/md5sums-$VER

echo  "Move files to build folder"
mv $BINDIR/openwrt*-squash*sysupgrade.bin $BINDIR/builds/build-$DIR
mv $BINDIR/openwrt*kernel.bin     $BINDIR/builds/build-$DIR
mv $BINDIR/openwrt*squashfs.bin   $BINDIR/builds/build-$DIR
echo ""

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

build_mp02 MP02 

echo " "
echo " Build script MP02 CR complete"
echo " "
echo '----------------------------'

exit

