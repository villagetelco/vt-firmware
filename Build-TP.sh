#! /bin/sh

# Build script for TP Link devices

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
DIR=$DATE"-TP-"$DIRVER

###########################

# Set up build directory
echo "New build directory  ./bin/ar71xx/builds/build-"$DIR
mkdir ./bin/ar71xx/builds/build-$DIR

# Create md5sums file
touch ./bin/ar71xx/builds/build-$DIR/md5sums

###########################

echo '----------------------------'

echo "Set up files for WR842 "
DEVICE="WR842"

rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/WR842/files .        ; echo "Overlay device specific files"
./FactoryRestore.sh											; echo "Build Factory Restore tar file"

echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " TP-Link " $DEVICE   > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for WR842"
rm ./.config
cp ./SECN-build/WR842/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WR842/.config 

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for WR842"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*-squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*-squash*factory.bin    ./bin/ar71xx/builds/build-$DIR

echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End WR842 build"
echo ""

##################
#exit  #  Uncomment to end the build process here

echo '----------------------------'

echo "Set up files for MR3020 "
DEVICE="MR3020"
rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/MR3020/files .       ; echo "Overlay device specific files"
./FactoryRestore.sh											; echo "Build Factory Restore tar file"
echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " TP-Link " $DEVICE   > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for MR3020 "
rm ./.config
cp ./SECN-build/MR3020/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/MR3020/.config 

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for MR3020"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End MR3020 build"
echo ""

##################
#exit  #  Uncomment to end the build process here

echo '----------------------------'

echo "Set up files for WR703 "
DEVICE="WR703"

rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/WR703/files .        ; echo "Overlay device specific files"

./FactoryRestore.sh											; echo "Build Factory Restore tar file"

echo "Check files "
ls -al ./files   
echo " "

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " TP-Link " $DEVICE   > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for WR703 "
rm ./.config
cp ./SECN-build/WR703/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WR703/.config 

echo "Check .config version and target"
cat ./.config | grep "OpenWrt version"
cat ./.config | grep "CONFIG_TARGET" | grep "generic_" | grep "=y"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for WR703"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*wr703*squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*wr703*squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End WR703 build"
echo ""

###############
#exit  #  Uncomment to end the build process here


echo '----------------------------'

echo "Set up files for WDR4300"
DEVICE="WDR4300"

rm -r ./files/*
cp -r ./SECN-build/files         .        ; echo "Copy generic files"
cp -r ./SECN-build/WDR4300/files .        ; echo "Overlay device specific files"
./FactoryRestore.sh					  						; echo "Build Factory Restore tar file"
echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " TP-Link " $DEVICE   > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for WDR4300 "
rm ./.config
cp ./SECN-build/WDR4300/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WDR4300/.config 

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for WDR4300"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*wdr4300*squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*wdr4300*squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End WDR4300 build"
echo ""

#################
#exit  #  Uncomment to end the build process here


echo '----------------------------'


echo "Set up files for MR11U "
DEVICE="MR11U"
rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/MR11U/files .        ; echo "Overlay device specific files"
./FactoryRestore.sh											; echo "Build Factory Restore tar file"
echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " TP-Link " $DEVICE   > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for MR11U "
rm ./.config
cp ./SECN-build/MR11U/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/MR11U/.config 

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for MR11U"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End MR11U build"
echo ""

##################
#exit  #  Uncomment to end the build process here

echo '----------------------------'


echo "Set up files for MR3420 "
DEVICE="MR3420"

rm -r ./files/*
cp -r ./SECN-build/files        .       ; echo "Copy generic files"
cp -r ./SECN-build/MR3420/files .       ; echo "Overlay device specific files"
./FactoryRestore.sh											; echo "Build Factory Restore tar file"
echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " TP-Link " $DEVICE   > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for MR3420 "
rm ./.config
cp ./SECN-build/MR3420/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/MR3420/.config 

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for MR3420"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*-squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*-squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End MR3420 build"
echo ""

##################
#exit  #  Uncomment to end the build process here

echo '----------------------------'


echo "Set up files for WR841 "
DEVICE="WR841"

rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/WR841/files .        ; echo "Overlay device specific files"
./FactoryRestore.sh											; echo "Build Factory Restore tar file"
echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " TP-Link " $DEVICE   > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for WR841 "
rm ./.config
cp ./SECN-build/WR841/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WR841/.config 

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for WR841"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*-squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*-squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End WR841 build"
echo ""

##################
#exit  #  Uncomment to end the build process here

echo '----------------------------'


echo "Set up files for WR741 "
DEVICE="WR741"

rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/WR741/files .        ; echo "Overlay device specific files"
./FactoryRestore.sh											; echo "Build Factory Restore tar file"
echo "Check files "
ls -al ./files   
echo ""

# Set up version file
echo "Version: "  $VER $DEVICE
echo $VER  " TP-Link " $DEVICE   > ./files/etc/secn_version
echo "Date stamp the version file: " $DATE
echo "Build date " $DATE         >> ./files/etc/secn_version
echo " "                         >> ./files/etc/secn_version

echo "Set up .config for WR741 "
rm ./.config
cp ./SECN-build/WR741/.config  ./.config
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WR741/.config 

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Check banner version"
cat ./files/etc/secn_version | grep "Version"
echo ""

echo "Run make for WR741"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*-squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*-squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End WR741 build"
echo ""

##################
#exit  #  Uncomment to end the build process here

echo '----------------------------'



echo " Build script complete"; echo " "


