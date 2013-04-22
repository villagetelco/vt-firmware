#! /bin/sh

# Build script for MP-1 devices

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
VER="Version 2.0 Beta 1f"
DIRVER="Beta-1f"

###########################

echo "Copy files from Git repo into build folder"
rm -r ./files
cp -r -f ~/Git/SECN2-test/SECN-build/MP/files .

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-MP-"$DIRVER

# Set up build directory
echo "Set up new build directory  ./bin/mp/builds/build-"$DIR
mkdir ./bin/atheros/builds/build-$DIR

# Create md5sums file
touch ./bin/atheros/builds/build-$DIR/md5sums

###########################

echo '----------------------------'

echo "Set up files for MP-1"
DEVICE="MeshPotato-1"

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

# Check
echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for MP-1"
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



