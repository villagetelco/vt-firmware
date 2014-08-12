#!/bin/sh

# /bin/setgateway.sh
# This script is called from Asterisk IVR GATE command 4283
# Sets Gateway IP address in network config
# author TLG

# Get PIN and Gateway from temp file created by Asterisk and delete
PINNUM=`cat /tmp/gwoctet.txt  | awk '{ print $1 }'`
GWOCTET=`cat /tmp/gwoctet.txt | awk '{ print $2 }'`
rm /tmp/gwoctet.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
echo Pin Fail  > /tmp/test.txt
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Test for valid address (0 < gwoctet < 255, except 999, no * chars) and exit if invalid
if [ $GWOCTET != "999" ] && [ $GWOCTET -gt "254" ] || [ $GWOCTET -lt "1" ] || [ `echo $GWOCTET | grep "*"` ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Build the gateway IP from MP address and GW octet
GW1=`uci get network.lan.ipaddr | awk -F. '{print $1"."$2"."$3}'`
GW=`echo $GW1"."$GWOCTET`

# If the Gateway code entered is 999, find the gateway automatically
if [ $GWOCTET = "999" ]; then
  /bin/testgw.sh
  GW=`cat /tmp/gateway.txt | grep .`
  fi

# Save the gateway IP address
uci set network.lan.gateway=$GW
uci commit network

# Setup success message
cp /usr/lib/asterisk/sounds/completed-restart.gsm /usr/lib/asterisk/sounds/result.gsm

exit


