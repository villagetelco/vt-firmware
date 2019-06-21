#!/usr/bin/env bash

# Set default version parameters

# REVISION will be used if set to TRUE
SETREV="FALSE"
REVISION="18.06" # Specify named revision 

# TAG will be used if SETREV is FALSE
SETTAG="TRUE" 
TAG="v18.06.2" 

USAGE1="Usage:   ./Setup-OpenWrt-18_06.sh   /your-preferred-source-installation-path "
USAGE2="Example: ./Setup-OpenWrt-18_06.sh   ~/OpenWrt/my-new-build-env"

if (( $# < 1 ))
then
	echo " "
	echo "Error. Not enough arguments."
	echo $USAGE1
	echo $USAGE2
	echo " "
	exit 1
elif (( $# > 1 ))
then
	echo " "
	echo "Error. Too many arguments."
	echo $USAGE1
	echo $USAGE2
  echo " "
	exit 2
elif [ $1 == "--help" ]
then
	echo " "
	echo $USAGE1
	echo $USAGE2
        echo " "
	exit 3
fi

# Get the installation path
OPENWRT_PATH=$1

echo "******************"
echo ""
echo "Setting up OpenWrt development environment"
echo ""

if [ $SETREV == "TRUE" ]; then
	echo "*** Check out a specific revision: $REVISION"
	REV=";openwrt-$REVISION"
fi

if [ $SETTAG == "TRUE" ]; then
	echo "*** Check out a specific TAG: $TAG"
fi
echo " "

echo " "
echo "*** Installing to: " $1
echo "*** Revision:       "$REVISION
if [ $SETTAG == "TRUE" ]; then
	echo "*** TAG:            "$TAG
fi
echo " "


echo "Set up pre-requisites"
echo "This requires your password for sudo access and takes a few minutes."
echo "Please ensure you have a good Internet connection for the downloads"
echo "See ./apt-get.log"
echo " "

sudo apt-get update > ./apt-get.log
sudo apt-get install -y git-core build-essential libssl-dev libncurses5-dev unzip >> ./apt-get.log
echo " "


echo "*** Clone the OpenWrt build environment - https://git.openwrt.org/openwrt/openwrt.git"
echo "*** Destination: " $OPENWRT_PATH

#####git clone https://git.openwrt.org/openwrt/openwrt.git  $OPENWRT_PATH


if [ !e $OPENWRT_PATH ]; then
  echo "\n\n ********** Failed to create build environment $OPENWRT_PATH  ************** \n\n"
  exit
fi

echo "*** Change to build directory "$OPENWRT_PATH
cd $OPENWRT_PATH
echo " "

echo "*** Checkout "
if [ $SETTAG == "TRUE" ]; then
	echo "*** Checkout tag: $TAG/"
	git checkout $TAG
	echo " "
	echo "*** Create new local branch: "$TAG"-VT"
	git checkout -b $TAG"-VT"
else
	echo "*** Checkout rev: $REVISION/"
	git checkout $REVISION
	echo " "
	echo "*** Create new local branch: "$REVISION"-VT"
	git checkout -b $REVISION"-VT"
fi
echo " "

echo "*** Backup original feeds.conf.default file "
cp feeds.conf.default  feeds.conf.default.bak
echo " "

echo "*** Add project repos to feeds.conf.default file"
##########
cat >> feeds.conf.default << EOF

# Project package feeds

src-git fxs git://github.com/villagetelco/vt-fxs-packages.git

EOF
#########

echo " "

echo "*** Update the feeds (See ./feeds-update.log)"

./scripts/feeds update -a  2>&1 | tee ./feeds-update.log
echo " "

echo "*** Install OpenWrt packages (See ./feeds-install.log)"

./scripts/feeds install -a -p packages         > feeds-install.log
./scripts/feeds install -a -p telephony       >> feeds-install.log
./scripts/feeds install -a -p routing         >> feeds-install.log
./scripts/feeds install -a -p luci            >> feeds-install.log
./scripts/feeds install -a -p fxs             >> feeds-install.log

echo " "

echo "*** Update all feeds"
./scripts/feeds update -a
echo " "

echo "*** Remove tmp directory"
rm -rf tmp/
echo " "

echo "*** Run make defconfig to set up initial .config file (see ./defconfig.log)"
make defconfig > defconfig.log
echo " "

echo "*** Backup the .config file"
cp .config .config.orig
echo " "

echo "*** Check pre-requisites"
make prereq 2>&1 | tee ./prereq.log
echo " "

echo "*** Make clean"
make clean
echo " "

echo "End of script"

