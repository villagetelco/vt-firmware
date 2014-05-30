#!/usr/bin/env bash

USAGE1="Usage:   ./install-secn2-build-env-AA.sh  /your-preferred-source-installation-path"
USAGE2="Example: ./install-secn2-build-env-AA.sh  ~/openwrt/my-new-build-env"

if (( $# < 1 ))
then
	echo "Error. Not enough arguments."
	echo $USAGE1
	echo $USAGE2
        echo " "
	exit 1
elif (( $# > 1 ))
then
	echo "Error. Too many arguments."
	echo $USAGE1
	echo $USAGE2
        echo " "
	exit 2
elif [ $1 == "--help" ]
then
	echo $USAGE1
	echo $USAGE2
        echo " "
	exit 3
fi

OPENWRT_PATH=$1
echo " "
echo " "
echo "*** Installing to " $1
echo " "
echo "*** Make new directory"
mkdir -p $OPENWRT_PATH
echo " "

echo "*** Get MP02 packages from GitHub repo"
git clone https://github.com/villagetelco/vt-mp02-package   $OPENWRT_PATH/vt-mp02-package

echo "*** Checkout the OpenWRT build environment"
sleep 2
svn co svn://svn.openwrt.org/openwrt/branches/attitude_adjustment/ $OPENWRT_PATH
echo " "

echo "*** Backup original feeds files if they exist"
sleep 2
mv $OPENWRT_PATH/feeds.conf.default  $OPENWRT_PATH/feeds.conf.default.bak
echo " "

echo "*** Create new feeds.conf.default file"
echo "src-link dragino2      $OPENWRT_PATH/vt-mp02-package/packages-AA"   		   >> $OPENWRT_PATH/feeds.conf.default
echo "src-git routing git://github.com/openwrt-routing/packages.git;for-12.09.x" >> $OPENWRT_PATH/feeds.conf.default
echo "src-svn  packages svn://svn.openwrt.org/openwrt/branches/packages_12.09"   > $OPENWRT_PATH/feeds.conf.default
echo " "

echo "*** Update the feeds (See ./feeds-update.log)"
sleep 2
$OPENWRT_PATH/scripts/feeds update > ./feeds-update.log
sleep 2
echo " "
tail -n 6 ./feeds-update.log
echo " "

echo "*** Copy MP02 Platform info "
sleep 2
rsync -avC $OPENWRT_PATH/vt-mp02-package/platform-AA/target/ $OPENWRT_PATH/target/
echo " "

echo "*** Install MP02 hardware packages"
sleep 2
$OPENWRT_PATH/scripts/feeds install -a -p dragino2
echo " "

echo "*** Install OpenWrt packages"
sleep 10
$OPENWRT_PATH/scripts/feeds install -a
echo " "

# Remove tmp directory
rm -rf $OPENWRT_PATH/tmp/

echo "*** Change to build directory"
cd $OPENWRT_PATH
echo " "

echo "*** Run make defconfig to set up initial .config file (see ./defconfig.log)"
make defconfig > ./defconfig.log

# Backup the .config file
cp .config .config.orig
echo " "

echo "End of script"

