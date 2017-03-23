#!/usr/bin/env bash

# Set default version parameters

# REVISION will be used if set to TRUE
SETREV="TRUE"
REVISION="17.01" # Specify named revision 

# SHA will be used if SETREV is FALSE
SETSHA="TRUE" 
SHA="0a3088cb4b"    # lede-17.01 as at 19/2/2017


USAGE1="Usage:   ./Setup-LEDE-01.sh   /your-preferred-source-installation-path "
USAGE2="Example: ./Setup-LEDE-01.sh   ~/LEDE/my-new-build-env"

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
LEDE_PATH=$1

echo "******************"
echo ""
echo "Setting up LEDE development environment"
echo ""

if [ $SETREV == "TRUE" ]; then
	echo "*** Check out a specific revision: $REVISION"
	REV=";lede-$REVISION"
else
  REV=" "
	REVISION="Trunk"
fi

if [ $SETSHA == "TRUE" ]; then
	echo "*** Check out a specific SHA: $SHA"
fi
echo " "

echo " "
echo "*** Installing to: " $1
echo "*** Revision:      "$REVISION
if [ $SETSHA == "TRUE" ]; then
	echo "*** SHA:           "$SHA
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


echo "*** Checkout the LEDE build environment - https://github.com/lede-project/source.git/$REVISION/"
git clone https://git.lede-project.org/source.git      $LEDE_PATH
#git clone https://github.com/lede-project/source.git   $LEDE_PATH
git checkout $REVISION
echo " "


if [ !e $LEDE_PATH ]; then
  echo "\n\n ********** Failed to create build environment $LEDE_PATH  ************** \n\n"
  exit
fi

echo "*** Change to build directory "$OPENWRT_PATH
cd $LEDE_PATH
echo " "

if [ $SETSHA == "TRUE" ]; then
	echo "*** Check out a specific SHA: $SHA"
	git checkout -q $SHA
	git reset --hard
elif [ $SETREV == "TRUE" ]; then            #If not using SHA
	echo "*** Check out Revision: $REVISION"
	git checkout "lede-$REVISION"
	git reset --hard
fi
echo " "


echo "*** Backup original feeds files if they exist"
mv feeds.conf.default  feeds.conf.default.bak
echo " "

echo "*** Create new feeds.conf.default file"

cat > feeds.conf.default << EOF
# Package feeds

src-git packages https://git.lede-project.org/feed/packages.git$REV

src-git routing https://git.lede-project.org/feed/routing.git$REV

src-git telephony https://git.lede-project.org/feed/telephony.git$REV

src-git fxs git://github.com/villagetelco/vt-fxs-packages.git

src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git

src-git targets https://github.com/openwrt/targets.git

src-git luci https://git.lede-project.org/project/luci.git

#src-git oldpackages http://git.openwrt.org/packages.git
#src-git video https://github.com/openwrt/video.git
#src-git management https://github.com/openwrt-management/packages.git
#src-link custom /usr/src/openwrt/custom-feed

EOF
###################

echo " "

echo "*** Update the feeds (See ./feeds-update.log)"

./scripts/feeds update -a  2>&1 | tee ./feeds-update.log
echo " "

echo "*** Install LEDE packages (See ./feeds-install.log)"

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

printf "###########\n LEDE\n" >> gitlog.txt
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

#src-git packages https://git.lede-project.org/feed/packages.git$REV
src-git packages https://git.lede-project.org/feed/packages.git^$SHA_PACKAGES 

#src-git routing https://git.lede-project.org/feed/routing.git$REV
src-git routing https://git.lede-project.org/feed/routing.git^$SHA_ROUTING 

#src-git telephony https://git.lede-project.org/feed/telephony.git$REV
src-git telephony https://git.lede-project.org/feed/telephony.git^$SHA_TELEPHONY 
#src-git telephony https://git.lede-project.org/feed/telephony.git^bbf0cbf # Specific Aster ver for FXS code compatibility

#src-git fxs git://github.com/villagetelco/vt-fxs-packages.git
src-git fxs git://github.com/villagetelco/vt-fxs-packages.git^$SHA_FXS 
#src-git fxs git://github.com/villagetelco/vt-fxs-packages.git^3d99242     # Specific version @ May 14 05:14:01 2015

#src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git
src-git alfred git://git.open-mesh.org/openwrt-feed-alfred.git^$SHA_ALFRED

src-git targets https://github.com/openwrt/targets.git
src-git luci https://git.lede-project.org/project/luci.git

#src-git oldpackages http://git.openwrt.org/packages.git
#src-git video https://github.com/openwrt/video.git
#src-git management https://github.com/openwrt-management/packages.git
#src-link custom /usr/src/openwrt/custom-feed

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

