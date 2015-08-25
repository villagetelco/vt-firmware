#! /bin/bash

# Default is for your local git repo to live in ../../Git
# If not, you can override by setting/exporting it in your .bashrc
: ${GITREPO="../../Git"}

# Select the repo to use
REPO="vt-firmware"
BRANCH="secn_3.0"

echo "Set up version strings"
DIRVER="GA01.1"
VER="SECN-3.0-TP-WDR-RACHEL-"$DIRVER


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
rm -rf ./SECN-build/
cp -rp $GITREPO/$REPO/SECN-build/ .
cp -fp $GITREPO/$REPO/Build-scripts/FactoryRestore.sh  .
cp -fp $GITREPO/$REPO/Build-scripts/GetGitVersions.sh  .

echo "Overlay RACHEL files"
cp -rp $GITREPO/$REPO/RACHEL-build/* ./SECN-build

###########################

BUILDPWD=`pwd`
cd  $GITREPO/$REPO
REPOID=`git describe --long --dirty --abbrev=10 --tags`
cd $BUILDPWD
echo "Source repo details: "$REPO $REPOID

###########################

# Set up new directory name with date and version
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-TP-WDR-RACHEL-"$DIRVER

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
	cp ./SECN-build/$1/config-$1-$2  ./.config
else
	echo "Config file: config-"$1
	cp ./SECN-build/$1/config-$1  ./.config
fi

echo "Run defconfig"
make defconfig > /dev/null

# Set up target display strings
TARGET="TL-"$1

echo "Check .config version"
echo "Target:  " $TARGET
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
#make -j5
make -j1 V=s 2>&1 | tee ~/build.txt
echo ""

# Get the hardware version eg (WDR) 4300 or 3500 
HWVER=`echo $1 | sed s/WDR//`

echo "Update original md5sums file"
cat $BINDIR/md5sums | grep "squashfs" | grep $HWVER | grep ".bin" >> $BUILDDIR/builds/build-$DIR/md5sums.txt
echo ""

echo  "Rename files to add version info"
echo ""
if [ $2 ]; then
	for n in `ls $BINDIR/openwrt*.bin | grep $HWVER`; do mv  $n   $BINDIR/openwrt-$VER-$2-`echo $n|cut -d '-' -f 5-10`; done
else
	for n in `ls $BINDIR/openwrt*.bin | grep $HWVER`; do mv  $n   $BINDIR/openwrt-$VER-`echo $n|cut -d '-' -f 5-10`; done
fi

echo "Update new md5sums file"
md5sum $BINDIR/*wdr$HWVER*-squash*sysupgrade.bin >> $BUILDDIR/builds/build-$DIR/md5sums-$VER.txt
#md5sum $BINDIR/*wdr$HWVER*-squash*factory.bin    >> $BUILDDIR/builds/build-$DIR/md5sums-$VER.txt

echo  "Copy files to build folder"
cp $BINDIR/openwrt*wdr$HWVER*-squash*sysupgrade.bin $BUILDDIR/builds/build-$DIR
#cp $BINDIR/openwrt*wdr$HWVER*-squash*factory.bin    $BUILDDIR/builds/build-$DIR
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

build_tp WDR4300
build_tp WDR3500


echo " "
echo "Build script TP WDR complete"
echo " "
echo '----------------------------'

exit


