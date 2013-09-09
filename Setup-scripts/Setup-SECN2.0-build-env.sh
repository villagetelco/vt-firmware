#!/usr/bin/env bash

USAGE="Usage: . ./install /your/preferred/source/installation/path"

if (( $# < 1 ))
then
	echo "Error. Not enough arguments."
	echo $USAGE
	exit 1
elif (( $# > 1 ))
then
	echo "Error. Too many arguments."
	echo $USAGE
	exit 2
elif [ $1 == "--help" ]
then
	echo $USAGE
	exit 3
fi

REPO_PATH=$(pwd)
OPENWRT_PATH=$1

mkdir $OPENWRT_PATH

echo " "
echo " Get SECN 2 packages from GitHub repo"
git clone https://github.com/villagetelco/vt-secn2-packages $OPENWRT_PATH/vt-secn2-packages

echo " "
echo "*** Checkout the OpenWRT build environment to the path specified on the command line"
sleep 5
mkdir -p $OPENWRT_PATH
svn co svn://svn.openwrt.org/openwrt/trunk/@r33887 $OPENWRT_PATH

echo " "
echo "*** Backup original feeds files if they exist"
sleep 5
mv $OPENWRT_PATH/feeds.conf.default $OPENWRT_PATH/feeds.conf.default.bak
mv $OPENWRT_PATH/feeds.conf $OPENWRT_PATH/feeds.conf.bak

echo " "
echo "***Create new 'feeds.conf.default' file for OpenWrt feed"
echo "src-svn packages svn://svn.openwrt.org/openwrt/packages@33887" > $OPENWRT_PATH/feeds.conf.default
echo " "
echo "***Update the OpenWrt feed"
sleep 5
$OPENWRT_PATH/scripts/feeds update

echo " "
echo "***Create new 'feeds.conf.default' file for VT feeds"
# This line is just for the record
echo "#src-svn packages svn://svn.openwrt.org/openwrt/packages@33887"       > $OPENWRT_PATH/feeds.conf.default
# These are the active lines
echo "src-link dragino2   $OPENWRT_PATH/vt-secn2-packages/packages"         >> $OPENWRT_PATH/feeds.conf.default
echo "src-link alfred     $OPENWRT_PATH/vt-secn2-packages/packages"         >> $OPENWRT_PATH/feeds.conf.default
echo "src-link batman-adv $OPENWRT_PATH/vt-secn2-packages/packages/routing" >> $OPENWRT_PATH/feeds.conf.default

# Original feeds for the record
#echo "src-git routing git://github.com/openwrt-routing/packages.git" >> $OPENWRT_PATH/feeds.conf.default
#echo "src-git telephony http://feeds.openwrt.nanl.de/openwrt/telephony.git" >> $OPENWRT_PATH/feeds.conf.default
#echo "src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git" >> $OPENWRT_PATH/feeds.conf.default

echo " "
echo "***Update the package feeds"
sleep 5
$OPENWRT_PATH/scripts/feeds update

echo " "
echo "***Copy MP02 Platform info"
sleep 5
rsync -avC $OPENWRT_PATH/vt-secn2-packages/platform/target/ $OPENWRT_PATH/target/

echo " "
echo "***Install MP02 hardware packages"
sleep 5
$OPENWRT_PATH/scripts/feeds install -a -p dragino2

echo " "
echo "*** Install packages"
sleep 5
$OPENWRT_PATH/scripts/feeds install kmod-batman-adv  
$OPENWRT_PATH/scripts/feeds install openssh-sftp-server
$OPENWRT_PATH/scripts/feeds install usb-modeswitch
$OPENWRT_PATH/scripts/feeds install usb-modeswitch-data 
$OPENWRT_PATH/scripts/feeds install haserl 
$OPENWRT_PATH/scripts/feeds install xinetd
$OPENWRT_PATH/scripts/feeds install muninlite
$OPENWRT_PATH/scripts/feeds install alfred

#rm tmp directory
rm -rf $OPENWRT_PATH/tmp/

# Change to build directory
cd $OPENWRT_PATH

echo " "
echo "*** Run < make menuconfig > to check and save configuration "
echo " "

# End of script
