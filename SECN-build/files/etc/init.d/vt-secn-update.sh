#! /bin/sh

# This script runs USB update script if required

UPDATEDIR="/mnt/sda1/VT-SECN-update"
UPDATESCRIPT="VT-SECN-update.sh"

if [ -e "$UPDATEDIR/$UPDATESCRIPT" ]; then
	cp $UPDATEDIR/$UPDATESCRIPT /tmp/$UPDATESCRIPT
	chmod +x /tmp/$UPDATESCRIPT
else
	#echo "Failed to find update script"
	exit
fi

# Get  first 10 characters of md5sums
MD5=`cat  $UPDATEDIR/VT-SECN-update.md5 | sed 's/^[ \t]*//;s/[ \t]*$//'`
UPDATEMD5=`md5sum /tmp/$UPDATESCRIPT | cut -d " " -f 1 | sed 's/^[ \t]*//;s/[ \t]*$//'`
MD5=`echo ${MD5:0:10}`
UPDATEMD5=`echo ${UPDATEMD5:0:10}`

# Check md5sums match and run the script if so.
if [ "$MD5" = "$UPDATEMD5" ]; then
	# Run update script
	/tmp/$UPDATESCRIPT
	#echo "Update script run" > /tmp/updatestatus.txt
else 
	# md5sum check failed
	exit
fi

