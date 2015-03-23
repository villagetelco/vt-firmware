#!/bin/sh

# /bin/reset-config.sh
# This script is called from Asterisk IVR RESET code

# Get reset confirm code from temp file created by asterisk
RESET=`cat /tmp/reset.txt`

if [ $RESET = "1" ]; then
    cd /etc/config
	tar -xzvf conf-default.tar.gz >> /dev/null
	cd
	/etc/init.d/config_secn > /dev/null  # Create new config files
	rm /tmp/reset.txt
	exit
fi

exit
