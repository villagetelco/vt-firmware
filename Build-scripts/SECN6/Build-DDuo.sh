#! /bin/bash

# Default is for your local git repo to live in ../../Git
# If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO="../../Git"}

# Select the repo to use
REPO="vt-firmware"
BRANCH="secn5"

echo "Set up version strings"
DIRVER="Alpha1"
VER="SECN-5-DDuo-"$DIRVER


echo "************************************"
echo ""
echo "Build script for Dragino Duo devices"

echo "Git directory: "$GITREPO
echo "Repo: "$REPO
echo " "

if [ ! -d $GITREPO"/"$REPO ]; then
	echo "Repo does not exist. Exiting build process"
	echo " "
	exit
fi


echo "Check out the correct vt-firmware branch - $BRANCH"

BUILD_DIR=$(pwd)
cd $GITREPO"/"$REPO
git checkout $BRANCH > /dev/null
# Make sure checkout worked
CHK_BR=`git branch | grep "*" | cut -d " " -f2`
if [ $CHK_BR != $BRANCH ]; then
	echo "Branch checkout failed"
	echo "*****"
	exit
else
	echo "Branch checkout successful"
fi
git branch | grep "*"
cd $BUILD_DIR
pwd

##############################

# Check to see if setup has already run
if [ ! -f ./already_configured ]; then 
  # make sure it only executes once
  touch ./already_configured  
  echo "Make builds directory"
  mkdir ./Builds/
  mkdir ./Builds/ar71xx/
  mkdir ./Builds/ar71xx/builds
  mkdir ./Builds/ramips/
  mkdir ./Builds/ramips/builds
  echo "Initial set up completed. Continuing with build"
  echo ""
else
  echo "Build environment is configured. Continuing with build"
  echo ""
fi


#########################

echo "Start build process"

BINDIR="./bin/targets/ramips/mt7628"
BUILDDIR="./Builds/ramips"

###########################
echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp $GITREPO/$REPO/SECN-build/ .
cp -fp $GITREPO/$REPO/Build-scripts/FactoryRestore.sh  .
cp -fp $GITREPO/$REPO/Build-scripts/GetGitVersions.sh  .


###########################

BUILDPWD=`pwd`
cd  $GITREPO/$REPO
REPOID=`git describe --long --dirty --abbrev=10 --tags`
cd $BUILDPWD
echo "Source repo details: "$REPO $REPOID

###########################

# Set up new directory name with date and version
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-DDuo-"$DIRVER

###########################
# Set up build directory
echo "Set up new build directory  $BUILDDIR/builds/build-"$DIR
mkdir $BUILDDIR/builds/build-$DIR

# Create md5sums file
echo $DIR > $BUILDDIR/builds/build-$DIR/md5sums-$VER.txt

##########################

# Build function

function build_dd() {

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

echo "Check .config version"
echo "Target:  " $TARGET
echo ""

echo "Set up files for "$1 $2
echo "Remove files directory"
rm -r ./files

echo "Copy base files"
cp -rf ./SECN-build/files             .  

echo "Copy additional files"
cp -rf ./SECN-build/files-2/*         ./files  
cp -rf ./SECN-build/files-aster/*     ./files  
cp -rf ./SECN-build/files-usbmodem/*  ./files  

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

echo "Version:    " $VER $TARGET $2        > ./files/etc/secn_version
echo "Build date: " $DATE                 >> ./files/etc/secn_version
echo "GitHub:     " $REPO $REPOID         >> ./files/etc/secn_version
echo " "                                  >> ./files/etc/secn_version
echo ""

echo "Banner version info:"
cat ./files/etc/secn_version
echo ""

echo "Clean up any left over files"
#rm $BINDIR/lede-*
rm $BINDIR/*
echo ""

echo "Run make for "$1 $2

make -j1
#make -j3
#make -j1 V=s 2>&1 | tee ~/build.txt

echo "End of make for "$1 $2
ls -l $BINDIR

echo  "Rename files to add version info"
echo ""
if [ $2 ]; then
	for n in `ls $BINDIR/lede*.bin`; do mv  $n   $BINDIR/lede-$VER-$1-$2-`echo $n|cut -d '-' -f 4-10`; done
else
	for n in `ls $BINDIR/lede*.bin`; do mv  $n   $BINDIR/lede-$VER-$1-`echo $n|cut -d '-' -f 4-10`; done
fi

echo "Update new md5sums file"
md5sum $BINDIR/*-squash*sysupgrade.bin >> $BUILDDIR/builds/build-$DIR/md5sums-$VER.txt

echo  "Move files to build folder"
mv $BINDIR/lede*-squash*sysupgrade.bin $BUILDDIR/builds/build-$DIR
echo ""

echo "Clean up unused files"
####rm $BINDIR/lede-*
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

build_dd DDuo

echo " "
echo " Build script Dragino Duo complete"
echo " "
echo '----------------------------'

exit


