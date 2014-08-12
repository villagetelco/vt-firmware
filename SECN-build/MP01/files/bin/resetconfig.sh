#!/bin/sh

# /bin/resetconfig.sh
# This script is called from Asterisk IVR RESET code 73738
# Author TLG

# Get PIN and Confirmation code from temp file and delete
PINNUM=`cat /tmp/reset.txt | awk '{ print $1 }'`
RESET=`cat /tmp/reset.txt | awk '{ print $2 }'`
rm /tmp/reset.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check reset confirmation code and if not "1" set result message to fail and exit
if [ $RESET != "1" ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Restore configuration to factory defaults
cd /etc/config
tar -xzvf conf-default.tar.gz >> /dev/null
cd
/etc/init.d/config_secn > /dev/null  # Create new config files

# Setup success message
cp /usr/lib/asterisk/sounds/completed-restart.gsm /usr/lib/asterisk/sounds/result.gsm

exit
