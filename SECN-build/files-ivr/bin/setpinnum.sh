#!/bin/sh

# /bin/setpinnum.sh
# This script sets a new IVR PIN number from the IVR command 7466 PINN
# Author TLG

# Get PIN and new PINs from temp file and delete
PINNUM=`cat /tmp/setpinnum.txt   | awk '{ print $1 }'`
PINNUM1=`cat /tmp/setpinnum.txt | awk '{ print $2 }'`
PINNUM2=`cat /tmp/setpinnum.txt | awk '{ print $3 }'`
rm /tmp/setpinnum.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
  exit
  fi

# Check if new pins match, and if not set result message to FAIL and exit
if [ $PINNUM1 != $PINNUM2 ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
  exit
  fi

# Set the new pin and save
uci set secn.ivr.pin=$PINNUM1
uci commit secn 

# Setup success message
cp /usr/lib/asterisk/sounds/success.gsm /tmp/result.gsm

exit

