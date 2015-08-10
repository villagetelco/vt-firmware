#!/usr/bin/env bash

# Set default version parameters
REVISION="15.05"
SETSHA="TRUE"
SHA="48e7befb"    # 15.05 branch as at 5 Aug 2015


USAGE1="Usage:   ./Setup-BB-44952.sh  < /your-preferred-source-installation-path >"
USAGE2="Example: ./Setup-BB-44952.sh  < ~/openwrt/my-new-build-env"

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

REV="for-$REVISION"

echo " "
echo " "
echo "*** Installing to: " $1
echo "*** Revision: "$REVISION
if [ $SETSHA == "TRUE" ]; then
	echo "*** SHA:      $SHA"
fi
echo " "

echo "*** Checkout the OpenWRT build environment - git://git.openwrt.org/$REVISION/"
git clone git://git.openwrt.org/$REVISION/openwrt.git $OPENWRT_PATH   

echo "*** Change to build directory "$OPENWRT_PATH
cd $OPENWRT_PATH
echo " "

if [ $SETSHA == "TRUE" ]; then
	echo "*** Check out a specific rev SHA: $SHA"
	git checkout -q $SHA
	git reset --hard
fi
echo " "


echo "*** Backup original feeds files if they exist"
mv feeds.conf.default  feeds.conf.default.bak
echo " "


echo "*** Create new feeds.conf.default file"

cat > feeds.conf.default << EOF
# Package feeds

#src-git packages https://github.com/openwrt/packages.git;$REV
src-git packages https://github.com/openwrt/packages.git^1ee31bd            # for-15.05 @ 5/8/2015

#src-git telephony https://github.com/openwrt/telephony.git;$REV
src-git telephony https://github.com/openwrt/telephony.git^bbf0cbf          # Specific version to avoid bug in for-15.05 @ 5/8/2015

#src-git fxs git://github.com/villagetelco/vt-fxs-packages.git
src-git fxs git://github.com/villagetelco/vt-fxs-packages.git^3d99242       # Master @ 5/8/2015

#src-git routing https://github.com/openwrt-routing/packages.git;$REV
src-git routing https://github.com/openwrt-routing/packages.git^0e8fd18     # for-15.05 @ 5/8/2015

#src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git
src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git^472f627    # Master @ 5/8/2015

EOF
###################

echo " "

echo "*** Update the feeds (See ./feeds-update.log)"

./scripts/feeds update -a  2>&1 | tee ./feeds-update.log
echo " "

echo "*** Install OpenWrt packages (See ./feeds-install.log)"

./scripts/feeds install -a -p packages        2>&1   > feeds-install.log
./scripts/feeds install -a -p telephony       2>&1  >> feeds-install.log
./scripts/feeds install -a -p routing         2>&1  >> feeds-install.log
./scripts/feeds install -a -p fxs             2>&1  >> feeds-install.log
./scripts/feeds install -a -p alfred          2>&1  >> feeds-install.log

echo " "

cat feeds-install.log

echo " "


echo "*** Get Git commit IDs and create Git log file"

printf "Details of installed Git repos\n" > gitlog.txt

printf "###########\n OpenWrt\n" >> gitlog.txt
SHA_OPENWRT=`git    log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n Packages\n" >> gitlog.txt
SHA_PACKAGES=`git -C ./feeds/packages   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n Telephony\n" >> gitlog.txt
SHA_TELEPHONY=`git -C ./feeds/telephony   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n FXS\n" >> gitlog.txt
SHA_FXS=`git -C ./feeds/fxs   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n Routing\n" >> gitlog.txt
SHA_ROUTING=`git -C ./feeds/routing   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`

printf "###########\n Alfred\n" >> gitlog.txt
SHA_ALFRED=`git -C ./feeds/alfred   log -n 1 --abbrev-commit| grep -A 3 commit | tee -a gitlog.txt | grep commit | cut -d " " -f 2`


echo "*** Lock the package feeds"

cat > feeds.conf.default << EOF
# Package feeds

#src-git packages https://github.com/openwrt/packages.git;$REV
src-git packages https://github.com/openwrt/packages.git^$SHA_PACKAGES

#src-git telephony https://github.com/openwrt/telephony.git;$REV
src-git telephony https://github.com/openwrt/telephony.git^$SHA_TELEPHONY

#src-git fxs git://github.com/villagetelco/vt-fxs-packages.git
src-git fxs git://github.com/villagetelco/vt-fxs-packages.git^$SHA_FXS

#src-git routing https://github.com/openwrt-routing/packages.git;$REV
src-git routing https://github.com/openwrt-routing/packages.git^$SHA_ROUTING

#src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git
src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git^$SHA_ALFRED

EOF
###################

echo " "

echo "*** Remove tmp directory"
rm -rf tmp/

echo "*** Run make defconfig to set up initial .config file (see ./defconfig.log)"
make defconfig > defconfig.log

echo "*** Backup the .config file"
cp .config .config.orig
echo " "



echo "End of script"

