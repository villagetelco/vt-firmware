#! /bin/bash

# Default is for your local git repo to live in ../../Git
# If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO="../../Git"}

# Select the repo to use
REPO="vt-firmware"
BRANCH="xsce"

echo "Set up version strings"
DIRVER="XSCE-RC4"
VER="SECN-4.0-TP-"$DIRVER


echo "************************************"
echo ""
echo "Build script for TP Link devices"

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
  mkdir ./Builds/atheros/
  mkdir ./Builds/atheros/builds
  echo "Initial set up completed. Continuing with build"
  echo ""
else
  echo "Build environment is configured. Continuing with build"
  echo ""
fi


#########################

echo "Start build process"

BINDIR="./bin/ar71xx"
BUILDDIR="./Builds/ar71xx"

###########################
echo "Copy files from Git repo into build folder"
rm -rf ./XSCE-build/
cp -rp $GITREPO/$REPO/XSCE-build/ .
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
DIR=$DATE"-TP-"$DIRVER

###########################
# Set up build directory
echo "Set up new build directory  $BUILDDIR/builds/build-"$DIR
mkdir $BUILDDIR/builds/build-$DIR

# Create md5sums files
echo $DIR > $BUILDDIR/builds/build-$DIR/md5sums.txt
echo $DIR > $BUILDDIR/builds/build-$DIR/md5sums-$VER.txt

##########################

# Build function

function build_tp() {

echo "Set up .config for "$1 $2
rm ./.config

if [ $2 ]; then
	echo "Config file: config-"$1-$2
	cp ./XSCE-build/$1/config-$1-$2  ./.config
else
	echo "Config file: config-"$1
	cp ./XSCE-build/$1/config-$1  ./.config
fi

echo "Run defconfig"
make defconfig > /dev/null

# Set up target display strings
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
echo "Target:  " $TARGET
echo ""

echo "Set up files for "$1 $2
echo "Remove files directory"
rm -r ./files

echo "Copy base files"
cp -r ./XSCE-build/files     .  

# Add files for WR842 if required
if [ $1 = "WR842" ]; then
  cp -rf ./XSCE-build/files-2/*         ./files  
  cp -rf ./XSCE-build/files-aster/*     ./files  
  cp -rf ./XSCE-build/files-usbmodem/*  ./files  
fi

echo "Overlay device specific files"
cp -r ./XSCE-build/$1/files  .  
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
rm $BINDIR/openwrt-*
echo ""

echo "Run make for "$1 $2
#make
make -j3
#make -j5
#make -j1 V=s 2>&1 | tee ~/build.txt
echo ""

echo "Update original md5sums file"
cat $BINDIR/md5sums | grep "squashfs" | grep ".bin" >> $BUILDDIR/builds/build-$DIR/md5sums.txt
echo ""

echo  "Rename files to add version info"
echo ""
if [ $2 ]; then
	for n in `ls $BINDIR/openwrt*.bin`; do mv  $n   $BINDIR/$VER-$2-`echo $n|cut -d '-' -f 5-10`; done
else
	for n in `ls $BINDIR/openwrt*.bin`; do mv  $n   $BINDIR/$VER-`echo $n|cut -d '-' -f 5-10`; done
fi

echo "Update new md5sums file"
md5sum $BINDIR/*-squash*sysupgrade.bin >> $BUILDDIR/builds/build-$DIR/md5sums-$VER.txt
md5sum $BINDIR/*-squash*factory.bin    >> $BUILDDIR/builds/build-$DIR/md5sums-$VER.txt
echo ""

echo  "Move files to build folder"
mv $BINDIR/*-squash*sysupgrade.bin $BUILDDIR/builds/build-$DIR
mv $BINDIR/*-squash*factory.bin    $BUILDDIR/builds/build-$DIR
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

build_tp MR3020 XSCE
build_tp WR841 XSCE
build_tp WR842 XSCE

echo " "
echo "Build script TP complete"
echo " "
echo '----------------------------'

exit

