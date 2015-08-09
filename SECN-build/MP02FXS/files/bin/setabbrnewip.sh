#!/bin/sh

# /bin/setabbrnewip.sh
# Sets a new IP based on current address using a new last octet 
# Asterisk IVR command 2662
# Asterisk places the IP octet in /tmp/newip.txt
# Adapted from /bin/setnewip for last octet entry by TLG

# Get PIN from Asterisk temp file and delete
PINNUM=`cat /tmp/pin.txt`
rm /tmp/pin.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check for newip file
if [ ! -f /tmp/newip.txt ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Get IP address octet
IPOCTET=`cat /tmp/newip.txt`

# Check for valid IP octet, set Fail message and exit
if [ $IPOCTET -gt "254" ] || [ $IPOCTET -lt "1" ] || [ `echo $IPOCTET | grep "*"` ] ; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Build up the full IP address
OCTET_A=`uci show network.lan.ipaddr | cut -d = -f2 | cut -d . -f1`
OCTET_B=`uci show network.lan.ipaddr | cut -d = -f2 | cut -d . -f2`
OCTET_C=`uci show network.lan.ipaddr | cut -d = -f2 | cut -d . -f3`

IPADDR=$OCTET_A.$OCTET_B.$OCTET_C.$IPOCTET

# Check to see if the IP address is already in use, fail and exit if it is in use
PING=`ping -c 1 $IPADDR | grep "bytes from" | cut -d " " -f2`

if [ $PING = "bytes" ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Save the IP and Gateway addresses
uci set network.lan.ipaddr=$IPADDR
uci commit network

# Set up result message to success and reboot 
cp /usr/lib/asterisk/sounds/completed-restart.gsm /usr/lib/asterisk/sounds/result.gsm

  
