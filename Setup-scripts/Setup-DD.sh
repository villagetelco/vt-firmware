#!/usr/bin/env bash

# Set default version parameters
REVISION="DD-A"
SETSHA="TRUE" ###############################################################
SHA="6bdf9ae2fe3c3"    # trunk as at 2 April 2016


USAGE1="Usage:   ./Setup-DD.sh   /your-preferred-source-installation-path "
USAGE2="Example: ./Setup-DD.sh   ~/openwrt/my-new-build-env"

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
echo "*** Revision:      "$REVISION
if [ $SETSHA == "TRUE" ]; then
	echo "*** SHA:           "$SHA
fi
echo " "


echo "Set up pre-requisites"
echo "This requires your password for sudo access and takes a couple of minutes."
echo "Please ensure you have a good Internet connection for the downloads"
echo "See ./apt-get.log"
echo " "

sudo apt-get update > ./apt-get.log
sudo apt-get install -y git-core build-essential libssl-dev libncurses5-dev unzip >> ./apt-get.log
echo " "


echo "*** Checkout the OpenWRT build environment - git://git.openwrt.org/$REVISION/"
#git clone git://git.openwrt.org/$REVISION/openwrt.git $OPENWRT_PATH   
git clone git://git.openwrt.org/openwrt.git $OPENWRT_PATH   
echo " "

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
src-git telephony https://github.com/openwrt/telephony.git^bbf0cbf          # Specific version to avoid bug in "for-15.05" branch @ 5/8/2015

#src-git routing https://github.com/openwrt-routing/packages.git;$REV
src-git routing https://github.com/openwrt-routing/packages.git^0e8fd18     # for-15.05 @ 5/8/2015

#src-git fxs git://github.com/villagetelco/vt-fxs-packages.git
src-git fxs git://github.com/villagetelco/vt-fxs-packages.git^3d992429      # Master @ 5/8/2015

#src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git
src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git^472f627d     # Master @ 5/8/2015

EOF
###################

echo " "

echo "*** Update the feeds (See ./feeds-update.log)"

./scripts/feeds update -a  2>&1 | tee ./feeds-update.log
echo " "

echo "*** Install OpenWrt packages (See ./feeds-install.log)"

./scripts/feeds install -a -p packages         > feeds-install.log
./scripts/feeds install -a -p telephony       >> feeds-install.log
./scripts/feeds install -a -p routing         >> feeds-install.log
./scripts/feeds install -a -p fxs             >> feeds-install.log
./scripts/feeds install -a -p alfred          >> feeds-install.log

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

echo " "

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

