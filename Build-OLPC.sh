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
VER="OLPC SECN Version 2.0 RC2b"
DIRVER="RC2b"

###########################

echo "Copy files from Git repo into build folder"
rm -rf ./SECN-build
cp -rp ~/Git/vt-firmware/SECN-build/ .
echo "Overlay OLPC files"
cp -rp ~/Git/olpc/SECN-build/ .

###########################

echo "Set up new directory name with date and version"
DATE=`date +%Y-%m-%d-%H:%M`
DIR=$DATE"-OLPC-"$DIRVER

###########################

# Set up build directory
echo "New build directory  ./bin/ar71xx/builds/build-"$DIR
mkdir ./bin/ar71xx/builds/build-$DIR

# Create md5sums file
touch ./bin/ar71xx/builds/build-$DIR/md5sums

###########################

echo '----------------------------'

echo "Set up .config for TL-MR3020"
rm ./.config
cp ./SECN-build/MR3020/.config  ./.config
echo " Run defconfig"
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/MR3020/.config 

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for TL-MR3020 "
rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/MR3020/files .       ; echo "Overlay device specific files"
./FactoryRestore.sh											; echo "Build Factory Restore tar file"
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
echo '----------------------------'

##################
#exit  #  Uncomment to end the build process here

echo "Set up .config for TL-WR842"
rm ./.config
cp ./SECN-build/WR842/.config  ./.config
echo " Run defconfig"
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WR842/.config 

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for TL-WR842 "
rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/WR842/files .        ; echo "Overlay device specific files"
./FactoryRestore.sh			; echo "Build Factory Restore tar file"

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
echo '----------------------------'

##################
exit  #  Uncomment to end the build process here

###############
#exit  #  Uncomment to end the build process here


echo "Set up .config for TL-WR741"
rm ./.config
cp ./SECN-build/WR741/.config  ./.config
echo " Run defconfig"
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WR741/.config 

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for TL-WR741"
rm -r ./files/*
cp -r ./SECN-build/files          .       ; echo "Copy generic files"
cp -r ./SECN-build/WR741/files   .       ; echo "Overlay device specific files"
./FactoryRestore.sh			  ; echo "Build Factory Restore tar file"

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
echo '----------------------------'

###############
#exit  #  Uncomment to end the build process here


echo "Set up .config for TL-WDR4300"
rm ./.config
cp ./SECN-build/WDR4300/.config  ./.config
echo " Run defconfig"
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WDR4300/.config 

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for TL-WDR4300 "
rm -r ./files/*
cp -r ./SECN-build/files          .       ; echo "Copy generic files"
cp -r ./SECN-build/WDR4300/files  .       ; echo "Overlay device specific files"
./FactoryRestore.sh			  ; echo "Build Factory Restore tar file"

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

echo "Run make for WDR4300"
make

echo  "Move files to build folder"
mv ./bin/ar71xx/*wdr4300*squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*wdr4300*squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*wdr4310*squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*wdr4310*squash*factory.bin    ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*wdr3600*squash*sysupgrade.bin ./bin/ar71xx/builds/build-$DIR
mv ./bin/ar71xx/*wdr3600*squash*factory.bin    ./bin/ar71xx/builds/build-$DIR

echo "Clean up unused files"
rm ./bin/ar71xx/openwrt-*
echo "Update md5sums"
cat ./bin/ar71xx/md5sums | grep "squashfs" | grep ".bin" >> ./bin/ar71xx/builds/build-$DIR/md5sums
echo ""
echo "End WDR4300 build"
echo ""
echo '----------------------------'

#################
exit  #  Uncomment to end the build process here
##################################################################################################

echo "Set up .config for TL-WR703"
rm ./.config
cp ./SECN-build/WR703/.config  ./.config
echo " Run defconfig"
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WR703/.config 

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for TL-WR703 "
rm -r ./files/*
cp -r ./SECN-build/files       .        ; echo "Copy generic files"
cp -r ./SECN-build/WR703/files .        ; echo "Overlay device specific files"
./FactoryRestore.sh			; echo "Build Factory Restore tar file"

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
echo '----------------------------'



echo "Set up .config for TL-MR3420"
rm ./.config
cp ./SECN-build/MR3420/.config  ./.config
echo " Run defconfig"
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/MR3420/.config 

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for TL-MR3420"
rm -r ./files/*
cp -r ./SECN-build/files          .       ; echo "Copy generic files"
cp -r ./SECN-build/MR3420/files   .       ; echo "Overlay device specific files"
./FactoryRestore.sh			  ; echo "Build Factory Restore tar file"

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
echo '----------------------------'

##################
#exit  #  Uncomment to end the build process here


echo "Set up .config for TL-WR841"
rm ./.config
cp ./SECN-build/WR841/.config  ./.config
echo " Run defconfig"
make defconfig > /dev/null
## Use for first build on a new revision to update .config file
cp ./.config ./SECN-build/WR841/.config 

# Get target device from .config file
TARGET=`cat .config | grep "CONFIG_TARGET" | grep "=y" | grep "_generic_" | cut -d _ -f 5 | cut -d = -f 1 `

echo "Check .config version"
cat ./.config | grep "OpenWrt version"
echo "Target:  " $TARGET

echo "Set up files for TL-WR841"
rm -r ./files/*
cp -r ./SECN-build/files          .       ; echo "Copy generic files"
cp -r ./SECN-build/WR841/files   .       ; echo "Overlay device specific files"
./FactoryRestore.sh			  ; echo "Build Factory Restore tar file"

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
echo '----------------------------'

##################
#exit  #  Uncomment to end the build process here


echo " Build script complete"; echo " "
echo '----------------------------'


