#! /bin/sh

# This script will perform a firmware upgrade if the USB update directory contains a
# *sysupgrade.bin file, and matching *sysupgrade.md5 and *sysupgrade.ver files.
# The md5 file contains the md5sum of the sysupgrade.bin file
# The ver file contains the version string as stored in /etc/secn_version
# The upgrade will be done if the md5sum is ok, and the version strings do not match.

# If the sysupgrade is not done, then the script will look for a .tar file and 
# a matching .tar.md5 file.
# The .tar.md5 file contains the md5sum of the .tar file
# If the md5sum is ok, the tar file will be extracted.

# An upgrade and an update (eg to set up config) can be done by booting twice with the USB.

echo "Start Update script" > /tmp/VT-SECN-update.log

UPDATEDIR="/mnt/sda1/VT-SECN-update"

if [ ! -d "$UPDATEDIR" ]; then
	echo "Update directory not found" >> /tmp/VT-SECN-update.log
	exit
fi 

########################

echo "Start Upgrade section" >> /tmp/VT-SECN-update.log

if [ -e $UPDATEDIR/*sysupgrade.bin ] && [ -e $UPDATEDIR/*sysupgrade.md5 ] && [ -e $UPDATEDIR/*sysupgrade.ver ]; then
	echo "Found sysupgrade files" >> /tmp/VT-SECN-update.log
	UPGRADEFILE=`ls $UPDATEDIR/*sysupgrade.bin | grep -m 1 "sysupgrade.bin"`
	UPGRADEMD5=`ls $UPDATEDIR/*sysupgrade.md5 | grep -m 1 "sysupgrade.md5"`
	UPGRADEVER=`ls $UPDATEDIR/*sysupgrade.ver | grep -m 1 "sysupgrade.ver"`

	# Copy the upgrade file to memory and get the md5sum
	if [ -n "$UPGRADEFILE" ]; then
		cp -f $UPGRADEFILE /tmp
		MD5=`md5sum /tmp/*sysupgrade.bin | sed 's/^[ \t]*//;s/[ \t]*$//'`
		MD5=`echo ${MD5:0:10}`
	fi

	# Get the reference md5sum
	if [ -n "$UPGRADEMD5" ]; then
		MD5CHECK=`cat $UPGRADEMD5 | sed 's/^[ \t]*//;s/[ \t]*$//'`
		MD5CHECK=`echo ${MD5CHECK:0:10}`
	fi

	# Get the reference version and current version strings, stripping spaces and tabs
	VERSION=`cat $UPGRADEVER | tr -d ' ' | tr -d '\t'`
	CURRVERSION=`grep "Version:" /etc/secn_version | tr -d ' '| tr -d '\t'`

	# Check md5 and version before performing sysupgrade
	if [ "$MD5" = "$MD5CHECK" ] && [ "$VERSION" != "$CURRVERSION" ]; then
		echo "About to upgrade firmware" >> /tmp/VT-SECN-update.log
		sysupgrade -n /tmp/$UPGRADEFILE
		exit
	else
		echo "No firmware upgrade performed - checks failed" >> /tmp/VT-SECN-update.log
	fi
else
	echo "No firmware upgrade performed - files not present" >> /tmp/VT-SECN-update.log
fi

##############################

echo "Start Update section" >> /tmp/VT-SECN-update.log

set +e
UPDATEFILE=`ls $UPDATEDIR/*.tar | grep -m 1 ".tar"`
UPDATEMD5=`ls $UPDATEDIR/*.tar.md5 | grep -m 1 ".tar.md5"`
set -e

# Get the md5sum of the tar file
if [ -n "$UPDATEFILE" ]; then
	MD5=`md5sum $UPDATEFILE | sed 's/^[ \t]*//;s/[ \t]*$//'`
	MD5=`echo ${MD5:0:10}`
else
	exit
fi

# Get the reference md5sum
if [ -n "$UPDATEMD5" ]; then
	MD5CHECK=`cat $UPDATEMD5 | sed 's/^[ \t]*//;s/[ \t]*$//'`
	MD5CHECK=`echo ${MD5CHECK:0:10}`
else
	exit
fi

echo $UPDATEFILE $MD5 $MD5CHECK >> /tmp/VT-SECN-update.log

#echo If the md5sum matches, extract the tar file
if [ $MD5 = $MD5CHECK ]; then
	echo "About to update" >> /tmp/VT-SECN-update.log
	tar -xf $UPDATEFILE
else
	echo "No update performed" >> /tmp/VT-SECN-update.log
fi

##################################

