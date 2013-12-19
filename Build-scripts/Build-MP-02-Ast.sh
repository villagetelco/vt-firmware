#! /bin/sh

# Build script for MP-02 devices

echo ""

# Check to see if setup has already run
if [ ! -f ./already_configured ]; then 
  # make sure it only executes once
  touch ./already_configured  
  echo " Make builds directory"
  mkdir ./bin/
  mkdir ./bin/ar71xx/
  mkdir ./bin/ar71xx/builds
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
DIRVER="Ast-RC3d"
VER="SECN Version 2.0 "$DIRVER

###########################

echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build/
cp -rp ~/Git/vt-firmware/SECN-build/        .
cp -fp ~/Git/vt-firmware/Build-scripts/FactoryRestore.sh  .

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-MP02-"$DIRVER

###########################

# Set up build directory
echo "New build directory  ./bin/ar71xx/builds/build-"$DIR
mkdir ./bin/ar71xx/builds/build-$DIR

# Create md5sums file
touch ./bin/ar71xx/builds/build-$DIR/md5sums

###########################

echo '----------------------------'

echo "Set up .config for MP-02"
rm ./.config
cp ./SECN-build/MP-02/config-MP02-Ast  ./.config
echo " Run defconfig"
make defconfig > /dev/null

# Set target as MP-02
TARGET="MP-02"

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for MP-02 "
rm -r ./files

echo "Copy generic files"
cp -r ./SECN-build/files       .  

echo "Overlay device specific files"
cp -r ./SECN-build/MP-02/files .    

echo "Build Factory Restore tar file"
./FactoryRestore.sh	 

echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $TARGET
echo $VER  $TARGET               > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version
 
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

#exit ##############################

echo "Run make for MP-02"
make -j8

echo  "Move files to build folder"
mv ./bin/ar71xx/openwrt*kernel.bin     ./bin/ar71xx/builds/build-$DIR/openwrt-MP02-$DIRVER-kernel.bin
mv ./bin/ar71xx/openwrt*squashfs.bin   ./bin/ar71xx/builds/build-$DIR/openwrt-MP02-$DIRVER-rootfs-squashfs.bin
mv ./bin/ar71xx/openwrt*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR/openwrt-MP02-$DIRVER-squashfs-sysupgrade.bin
mv ./bin/ar71xx/openwrt*u-boot.bin     ./bin/ar71xx/builds/build-$DIR

echo "Update md5sums"
cat ./bin/ar71xx/md5sums | sed s/dragino2/MP02-$DIRVER/ > ./bin/ar71xx/md5sums-MP02
cat ./bin/ar71xx/md5sums-MP02 | grep "MP02"    | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
cat ./bin/ar71xx/md5sums-MP02 | grep "u-boot"  | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums

echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
rm ./bin/ar71xx/md5*

echo ""
echo "End MP-02 build"
echo ""

##################

echo '----------------------------'

echo " Build script MP-02 complete"; echo " "


