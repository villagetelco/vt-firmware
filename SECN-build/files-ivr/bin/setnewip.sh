#!/bin/sh -x

# /bin/setnewip.sh  by David Rowe Nov 18 2007
# Modified for Openwrt's uci interface by Elektra
# Adapted for PIN by TLG
# Sets a new IP based on DTMF digits collected by Asterisk IVR command 2663
# Asterisk places its collected IP in /tmp/newip.txt

# Get PIN from Asterisk and delete
PINNUM=`cat /tmp/pin.txt`
rm /tmp/pin.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
  exit
  fi

# Check newip file
if [ ! -f /tmp/newip.txt ]; then
  exit
  fi

# Convert * seperated IP like 192*168*1*32 to 192.168.1.32
IPADDR=`cat /tmp/newip.txt | sed 's/\*/\./g' `

# Check to see if the IP address is already in use, fail and exit
PING=`ping -c 1 $IPADDR | grep "bytes from" | cut -d " " -f2`
if [ $PING = "bytes" ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
  exit
  fi

# Set IP address in config
uci set network.lan.ipaddr=$IPADDR

# Set the Gateway to .001 and Broadcast to .255 in the same subnet.
OCTET_A=`uci get network.lan.ipaddr | cut -d = -f2 | cut -d . -f1`
OCTET_B=`uci get network.lan.ipaddr | cut -d = -f2 | cut -d . -f2`
OCTET_C=`uci get network.lan.ipaddr | cut -d = -f2 | cut -d . -f3`
uci set network.lan.gateway=$OCTET_A.$OCTET_B.$OCTET_C".1"
uci set network.lan.broadcast=$OCTET_A.$OCTET_B.$OCTET_C".255"

# Save IP Gateway and Broadcast addresses
uci commit network

# Set up result message
cp /usr/lib/asterisk/sounds/completed-restart.gsm /tmp/result.gsm

# Remove the temp file
rm /tmp/newip.txt

