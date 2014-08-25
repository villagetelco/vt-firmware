#! /bin/sh

# Build script for MP01 devices

echo ""
# Check to see if setup has already run
if [ ! -f ./already_configured ]; then 
  # make sure it only executes once
  touch ./already_configured  
  echo " Make builds directory"
  mkdir ./bin/
  mkdir ./bin/atheros/
  mkdir ./bin/atheros/builds
  echo " Initial set up completed. Continuing with build"
  echo ""
else
  echo "Build environment is configured. Continuing with build"
  echo ""
fi

#########################

echo "Start build process"

# Set up version strings
VER="Version 2.0 Alpha-2"
DIRVER="Alpha-2"

###########################

echo "Copy files directory from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp ~/Git/vt-firmware/SECN-build/  .
cp -rp ./SECN-build/files  .

echo "Overlay MP01 specific files "
cp -rp ./SECN-build/MP01/files  .

echo "Copy driver code from Git repo into build folder"
rm -rf ./drivers
cp -rp ~/Git/vt-firmware/SECN-build/MP01/drivers  .

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-MP01-"$DIRVER

###########################

# Set up build directory
echo "Set up new build directory  ./bin/atheros/builds/build-"$DIR
mkdir ./bin/atheros/builds/build-$DIR

# Create md5sums file
touch ./bin/atheros/builds/build-$DIR/md5sums

###########################

echo '----------------------------'
echo "Make MP channel driver"
cd ./drivers/asterisk
make
echo "Copy files"
cp ./gentone       ../../files/usr/lib/asterisk/modules
cp ./chan_mp.so    ../../files/usr/lib/asterisk/modules
cd ../..

echo '----------------------------'
echo "Make 8250 driver"
cd ./drivers/driver
make
echo "Copy files"
cp ./8250mp.ko   ../../files/lib/modules/*
cp ./mp.ko       ../../files/lib/modules/*
cd ../..

echo '----------------------------'

echo "Set up .config for MP01"
rm ./.config
cp ./SECN-build/MP01/config-MP01  ./.config
make defconfig > /dev/null

echo '----------------------------'
echo "Set up files for MP01"
DEVICE="MP01"

echo "Check .config version"
cat ./.config | grep "OpenWrt version"

echo "Build Factory Restore tar file" 
./FactoryRestore.sh                     ; echo "Build Factory Restore tar file"

echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " " $DEVICE           > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for MP01"
make

echo  "Move files to build folder"
mv ./bin/atheros/*root.squashfs    ./bin/atheros/builds/build-$DIR
mv ./bin/atheros/*.lzma            ./bin/atheros/builds/build-$DIR

echo "Update md5sums"
cat ./bin/atheros/md5sums | grep "root.squashfs" >> ./bin/atheros/builds/build-$DIR/md5sums
cat ./bin/atheros/md5sums | grep "lzma"     >>      ./bin/atheros/builds/build-$DIR/md5sums

echo "Clean up unused files"
rm ./bin/atheros/openwrt-*
rm ./bin/atheros/md5sums

echo ""
echo "End MeshPotato-1 build"
echo ""

#exit


