#!/bin/sh

# /bin/setmpgw.sh
# This script is called from Asterisk IVR MPGW code 6749
# It sets the gateway mode on-the-fly and in uci configuration.
# Author TLG

# Get PIN and Confirmation code from temp file and delete
PINNUM=`cat /tmp/mpgw.txt | awk '{ print $1 }'`
MPGW=`cat /tmp/mpgw.txt | awk '{ print $2 }'`
rm /tmp/mpgw.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check code and if invalid, set Fail message and exit
if [ $MPGW -gt "2" ] || [ $MPGW = "*" ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check code and if "0" Set GW to Off
if [ $MPGW = "0" ]; then
  batctl gw off
  uci set batman-adv.bat0.gw_mode=off
  uci set secn.mpgw.mode=OFF
  fi
# Check code and if "1" Set GW to Server
if [ $MPGW = "1" ]; then
  batctl gw server
  uci set batman-adv.bat0.gw_mode=server
  uci set secn.mpgw.mode=SERVER
  fi
# Check code and if "2" Set GW to Client
if [ $MPGW = "2" ]; then
  batctl gw client
  uci set batman-adv.bat0.gw_mode=client
  uci set secn.mpgw.mode=CLIENT
  fi

# Save uci settings
uci commit batman-adv
uci commit secn

# Setup success message
cp /usr/lib/asterisk/sounds/success.gsm /usr/lib/asterisk/sounds/result.gsm
exit
