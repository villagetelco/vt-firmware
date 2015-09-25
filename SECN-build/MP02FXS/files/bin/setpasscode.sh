#!/bin/sh

# /bin/setpasscode.sh
# This script sets a new numeric WiFi Passcode from the IVR command 9434 WIFI
# Author TLG

# Get PIN and new Passcodes from temp file created by asterisk and delete
PINNUM=`cat /tmp/setpasscode.txt    | awk '{ print $1 }'`
PASSCODE1=`cat /tmp/setpasscode.txt | awk '{ print $2 }'`
PASSCODE2=`cat /tmp/setpasscode.txt | awk '{ print $3 }'`
rm /tmp/setpasscode.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
  exit
  fi

# Check if new Passcodes match, and if not set result message to FAIL and exit
if [ $PASSCODE1 != $PASSCODE2 ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
  exit
  fi

# Check Passcode is at least eight digits
LEN=`echo $PASSCODE1 | awk '{print length($0)}'`
if [ $LEN -lt 8 ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
  exit
  fi

# Set the new passcode and save
uci set secn.ap_0.passphrase=$PASSCODE1
uci commit secn 

# Setup success message
cp /usr/lib/asterisk/sounds/completed-restart.gsm /tmp/result.gsm

exit
