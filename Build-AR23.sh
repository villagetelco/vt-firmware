#! /bin/sh

# Build script for AR23xx devices

echo ""

# Check to see if setup script has already run
if [ ! -f ./already_configured ]; then 
  echo "Build environment not configured. Quitting now"
  exit
else
  echo "Build environment is configured. Continuing with build"
  echo ""
fi

#########################

echo "Start build process"

# Set up version strings
VER="Version 2.0 Beta 1e (r34386)"
DIRVER="Beta-1e"

###########################

echo "Copy files from Git repo into build folder"
rm -r ./SECN-build/files/*
cp -r -f ~/Git/SECN2-test/SECN-build/* ./SECN-build/

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-AR23-"$DIRVER

###########################

# Set up build directory
echo "Set up new build directory  ./bin/atheros/builds/build-"$DIR
mkdir ./bin/atheros/builds/build-$DIR

# Create md5sums file
touch ./bin/atheros/builds/build-$DIR/md5sums

###########################

echo '----------------------------'

echo "Set up files for AR231x"
DEVICE="Ubiquity AR231x"

rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/AR23/files  .        ; echo "Overlay device specific files"
./FactoryRestore.sh			 							 ; echo "Build Factory Restore tar file"

echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " " $DEVICE      > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for AR23"
rm ./.config
cp ./SECN-build/AR23/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/AR23/.config 

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for AR23"
make

echo  "Move files to build folder"
mv ./bin/atheros/*squash*    ./bin/atheros/builds/build-$DIR
mv ./bin/atheros/*.lzma      ./bin/atheros/builds/build-$DIR

echo "Update md5sums"
cat ./bin/atheros/md5sums | grep "squashfs" >> ./bin/atheros/builds/build-$DIR/md5sums
cat ./bin/atheros/md5sums | grep "lzma"     >> ./bin/atheros/builds/build-$DIR/md5sums

echo "Clean up unused files"
rm ./bin/atheros/openwrt-*

echo ""
echo "End Ubiquity-AR231x build"
echo ""

#exit


