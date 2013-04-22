#!/bin/sh

# /bin/setchan.sh
# This script is called from Asterisk IVR CHAN code 2426
# Author TLG

# Get PIN and Channel number from temp file and delete
PINNUM=`cat /tmp/chan.txt | awk '{ print $1 }'`
CHAN=`cat /tmp/chan.txt | awk '{ print $2 }'`
rm /tmp/chan.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check for valid channel number set result message to fail and exit
if [ $CHAN = "0" ] || [ $CHAN -gt "12" ] || [ `echo $CHAN | grep "*"` ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Set WiFi Channel
uci set wireless.wifi0.channel=$CHAN
uci commit wireless

# Setup success message
cp /usr/lib/asterisk/sounds/completed-restart.gsm /usr/lib/asterisk/sounds/result.gsm
exit
