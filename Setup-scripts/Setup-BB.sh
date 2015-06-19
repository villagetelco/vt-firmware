#!/usr/bin/env bash

USAGE1="Usage:   ./Setup-BB.sh  < /your-preferred-source-installation-path >  < revision >"
USAGE2="Example: ./Setup-BB.sh  < ~/openwrt/my-new-build-env  44952"

if (( $# < 2 ))
then
	echo " "
	echo "Error. Not enough arguments."
	echo $USAGE1
	echo $USAGE2
        echo " "
	exit 1
elif (( $# > 2 ))
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

# Get parameters
OPENWRT_PATH=$1
REVISION=$2

echo " "
echo " "
echo "*** Installing to " $1
echo "*** Revision: r"$REVISION
echo " "


echo "*** Make new directory"
mkdir -p $OPENWRT_PATH
echo " "

echo "*** Checkout the OpenWRT build environment"
sleep 2
svn checkout --revision=$REVISION svn://svn.openwrt.org/openwrt/branches/barrier_breaker/ $OPENWRT_PATH  > $OPENWRT_PATH/checkout.log
echo " "

echo "*** Backup original feeds files if they exist"
sleep 2
mv $OPENWRT_PATH/feeds.conf.default  $OPENWRT_PATH/feeds.conf.default.bak
echo " "

echo "*** Create new feeds.conf.default file"
echo "src-git pkgsmaster https://github.com/openwrt/packages.git"                           > $OPENWRT_PATH/feeds.conf.default
echo "src-git packages https://github.com/openwrt/packages.git;for-14.07"                   >> $OPENWRT_PATH/feeds.conf.default
echo "src-git telephony https://github.com/openwrt/telephony.git^47c2c1f"                   >> $OPENWRT_PATH/feeds.conf.default
echo "src-git routing https://github.com/openwrt-routing/packages.git;for-14.07"            >> $OPENWRT_PATH/feeds.conf.default
echo "src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git"                       >> $OPENWRT_PATH/feeds.conf.default
echo "src-git fxs git://github.com/villagetelco/vt-fxs-packages.git"                        >> $OPENWRT_PATH/feeds.conf.default
echo " "

echo "*** Update the feeds (See ./feeds-update.log)"
sleep 2
$OPENWRT_PATH/scripts/feeds update         > $OPENWRT_PATH/feeds-update.log
sleep 2
echo " "
tail -n 6 $OPENWRT_PATH/feeds-update.log
echo " "

$OPENWRT_PATH/scripts/feeds update -i      > $OPENWRT_PATH/feeds-update.log

echo "*** Install OpenWrt packages (See ./feeds-install.log)"
sleep 10
$OPENWRT_PATH/scripts/feeds install -a -p packages          > $OPENWRT_PATH/feeds-install.log
$OPENWRT_PATH/scripts/feeds install -a -p telephony         >> $OPENWRT_PATH/feeds-install.log
$OPENWRT_PATH/scripts/feeds install -a -p routing           >> $OPENWRT_PATH/feeds-install.log
$OPENWRT_PATH/scripts/feeds install -a -p alfred            >> $OPENWRT_PATH/feeds-install.log
$OPENWRT_PATH/scripts/feeds install -a -p fxs               >> $OPENWRT_PATH/feeds-install.log
$OPENWRT_PATH/scripts/feeds install php5                    >> $OPENWRT_PATH/feeds-install.log
echo " "

echo "*** Lock the OpenWrt package feeds from further updating"
echo "#src-git pkgsmaster https://github.com/openwrt/packages.git"                          > $OPENWRT_PATH/feeds.conf.default
echo "#src-git packages https://github.com/openwrt/packages.git;for-14.07"                  >> $OPENWRT_PATH/feeds.conf.default
echo "src-git telephony https://github.com/openwrt/telephony.git^47c2c1f"                   >> $OPENWRT_PATH/feeds.conf.default
echo "src-git routing https://github.com/openwrt-routing/packages.git;for-14.07"            >> $OPENWRT_PATH/feeds.conf.default
echo "src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git"                       >> $OPENWRT_PATH/feeds.conf.default
echo "src-git fxs git://github.com/villagetelco/vt-fxs-packages.git"                        >> $OPENWRT_PATH/feeds.conf.default
echo " "

echo "*** Remove tmp directory"
rm -rf $OPENWRT_PATH/tmp/

echo "*** Change to build directory "$OPENWRT_PATH
cd $OPENWRT_PATH
echo " "

echo "*** Run make defconfig to set up initial .config file (see ./defconfig.log)"
make defconfig > $OPENWRT_PATH/defconfig.log

echo "*** Backup the .config file"
cp .config .config.orig
echo " "

echo "End of script"

