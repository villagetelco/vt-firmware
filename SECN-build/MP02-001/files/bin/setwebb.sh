#!/bin/sh

# /bin/setwebb.sh
# This script is called from Asterisk IVR WEBB code 9322
# It sets the web server on or off on-the-fly and in startup.
# Author TLG

# Get PIN and Confirmation code from temp file and delete
PINNUM=`cat /tmp/webb.txt | awk '{ print $1 }'`
WEBB=`cat /tmp/webb.txt | awk '{ print $2 }'`
rm /tmp/webb.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check code and if invalid, set Fail message and exit
if [ $WEBB -gt "1" ] || [ $WEBB = "*" ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check code and if "0" Set webserver to Off
if [ $WEBB = "0" ]; then
  /etc/init.d/uhttpd stop
  /etc/init.d/uhttpd disable
  fi
# Check code and if "1" Set GW to Server
if [ $WEBB = "1" ]; then
  /etc/init.d/uhttpd start
  /etc/init.d/uhttpd enable  
  fi

# Setup success message
cp /usr/lib/asterisk/sounds/success.gsm /usr/lib/asterisk/sounds/result.gsm
exit
