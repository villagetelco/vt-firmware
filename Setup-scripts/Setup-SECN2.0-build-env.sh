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
echo " "
echo "*** Checkout the Dragino2 board repo to the current directory"
sleep 5
svn co http://svn.dragino.com/dragino2/    $REPO_PATH/dragino2

echo " "
echo "*** Checkout the OpenWRT build environment to the path specified on the command line"
sleep 5
mkdir -p $OPENWRT_PATH
svn co svn://svn.openwrt.org/openwrt/trunk/@r33887 $OPENWRT_PATH

echo " "
echo "*** Backup original feeds files"
sleep 5
mv $OPENWRT_PATH/feeds.conf.default $OPENWRT_PATH/feeds.conf.default.bak
mv $OPENWRT_PATH/feeds.conf $OPENWRT_PATH/feeds.conf.bak

echo " "
echo "Create new 'feeds.conf.default' file with lines for OpenWrt feed and Dragino feed"

echo "src-svn packages svn://svn.openwrt.org/openwrt/packages@33887"        > $OPENWRT_PATH/feeds.conf.default
echo "src-link dragino2 $REPO_PATH/dragino2/package"                        >> $OPENWRT_PATH/feeds.conf.default
echo "src-git telephony http://feeds.openwrt.nanl.de/openwrt/telephony.git" >> $OPENWRT_PATH/feeds.conf.default
echo "src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git"       >> $OPENWRT_PATH/feeds.conf.default

# Not reqd if batman-adv included in Dragino repo
#echo "src-git routing git://github.com/openwrt-routing/packages.git"      >> $OPENWRT_PATH/feeds.conf.default

echo " "
echo "***Update the feeds"
sleep 5
$OPENWRT_PATH/scripts/feeds update

echo " "
echo "***Copy Dragino2 Platform info"
sleep 5
rsync -avC $REPO_PATH/dragino2/platform/target/ $OPENWRT_PATH/target/

echo " "
echo "***Install Dragino packages"
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

# Change to new build directory
cd $OPENWRT_PATH

echo " "
echo "*** Run < make menuconfig > to check and save configuration "
echo " "

# End of script

