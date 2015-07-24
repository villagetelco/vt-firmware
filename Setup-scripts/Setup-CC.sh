#!/usr/bin/env bash

USAGE1="Usage:   ./Setup-CC.sh  /your-preferred-source-installation-path < revision >"
USAGE2="Example: ./Setup-CC.sh  ~/openwrt/my-new-build-env 45594"

if (( $# < 1 ))
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

OPENWRT_PATH=$1
REVISION=45594

if (( $# == 2 ))
then
    REVISION=$2
fi

echo " "
echo " "
echo "*** Installing to " $1
#echo "*** Revision: r"$REVISION
echo " "

echo "*** Checkout the OpenWRT build environment"
sleep 2
git clone git://git.openwrt.org/openwrt.git $OPENWRT_PATH                        

echo "*** Change to build directory "$OPENWRT_PATH
cd $OPENWRT_PATH
echo " "

echo "*** Checkout REVISION "$REVISION
COMMIT=`git log --grep=trunk@$REVISION | grep "^commit" | cut -f2 -d' '`
git checkout $COMMIT                                                             
echo " "

echo "*** Backup original feeds files if they exist"
sleep 2
mv feeds.conf.default  feeds.conf.default.bak
echo " "

echo "*** Create new feeds.conf.default file"
echo "src-git packages https://github.com/openwrt/packages.git"                        > feeds.conf.default
#echo "src-git telephony https://github.com/openwrt/telephony.git^47c2c1f"             >> feeds.conf.default
echo "src-git telephony https://github.com/openwrt/telephony.git"                      >> feeds.conf.default
echo "src-git routing https://github.com/openwrt-routing/packages.git"                 >> feeds.conf.default
#echo "src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git"                 >> feeds.conf.default
echo "src-git fxs git://github.com/villagetelco/vt-fxs-packages.git"                   >> feeds.conf.default
echo " "

echo "*** Update the feeds (See ./feeds-update.log)"
sleep 2
./scripts/feeds update         > feeds-update.log
sleep 2
echo " "
tail -n 6 feeds-update.log
echo " "

./scripts/feeds update -i      > feeds-update.log

echo "*** Install OpenWrt packages (See ./feeds-install.log)"
sleep 10
./scripts/feeds install -a -p packages          > feeds-install.log
./scripts/feeds install -a -p telephony         >> feeds-install.log
./scripts/feeds install -a -p routing           >> feeds-install.log
#./scripts/feeds install -a -p alfred            >> feeds-install.log
./scripts/feeds install -a -p fxs               >> feeds-install.log
echo " "

echo "*** Lock the OpenWrt package feeds from further updating"
echo "#src-git packages https://github.com/openwrt/packages.git"                      > feeds.conf.default
#echo "src-git telephony https://github.com/openwrt/telephony.git^47c2c1f"            >> feeds.conf.default
echo "src-git telephony https://github.com/openwrt/telephony.git"                     >> feeds.conf.default
echo "src-git routing https://github.com/openwrt-routing/packages.git"                >> feeds.conf.default
#echo "src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git"                >> feeds.conf.default
echo "src-git fxs git://github.com/villagetelco/vt-fxs-packages.git"                  >> feeds.conf.default
echo " "

echo "*** Remove tmp directory"
rm -rf tmp/

echo "*** Run make defconfig to set up initial .config file (see ./defconfig.log)"
make defconfig > defconfig.log

echo "*** Backup the .config file"
cp .config .config.orig
echo " "

echo "End of script"

