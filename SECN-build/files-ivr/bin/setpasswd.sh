#!/bin/sh
# This script sets a new root account password from IVR command 7277 PASS
# Author TLG

# Get PIN and Passwords 
PIN=`cat /tmp/passwd.txt   | awk '{ print $1 }'`
PASS1=`cat /tmp/passwd.txt | awk '{ print $2 }'`
PASS2=`cat /tmp/passwd.txt | awk '{ print $3 }'`

# Check the pin, and if not matched, set result message to FAIL and exit
PINN=`uci get secn.ivr.pin`
if [ $PIN != $PINN ]; then
	cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
	exit
fi

# Check for password match, and if not set result message to FAIL and exit
if [ $PASS1 != $PASS2 ]; then
	cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
	exit
fi

# Set the password and log the result
date > /tmp/setpassword.txt
(echo $PASS1; sleep 1; echo $PASS2) | /usr/bin/passwd root >> /tmp/setpassword.txt

# Success message
cp /usr/lib/asterisk/sounds/success.gsm /tmp/result.gsm

# Remove password temp file created by asterisk
rm /tmp/passwd.txt

exit



