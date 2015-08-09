#!/bin/sh

# /bin/setdhcp.sh
# This script is called from Asterisk IVR DHCP code 3427
# It enables the DHCP server on the br-lan:9 MP Fallback IP address
# It provides only a single IP address (172.31.255.253) to a client
# so that the client can access the MP on the Fallback address (172.31.255.254)
# for the purpose of setting up the MP configuration immediately after 
# flashing with the SECN firmware.
# The DHCP service only runs until the MP is restarted or the udhcpd daemon is terminated manually.
# Author TLG

# Get PIN and Confirmation code from temp file and delete
PINNUM=`cat /tmp/dhcp.txt | awk '{ print $1 }'`
DHCP=`cat /tmp/dhcp.txt | awk '{ print $2 }'`
rm /tmp/dhcp.txt

# Check the pin, and if not matched, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check code and if invalid, set Fail message and exit
if [ $DHCP -gt "1" ] || [ $DHCP = "*" ]; then
  cp /usr/lib/asterisk/sounds/fail.gsm /usr/lib/asterisk/sounds/result.gsm
  exit
  fi

# Check code and if "0" Disable DHCP
if [ $DHCP = "0" ]; then
  killall udhcpd
  fi

# Check to see if there is any other DHCP running on the network
# Take fail exit if one is detected.
# tbd

# Check code and if "1" Enable DHCP
if [ $DHCP = "1" ]; then
  # Terminate any currently running instances of udhcpd
  killall udhcpd > /dev/null

  # Make a new lease file
  rm /tmp/udhcpd.leases > /dev/null
  touch /tmp/udhcpd.leases

  # Set up log file
  date > /tmp/udhcpd.log

  # Start the server with IVR conf and log activity
  udhcpd -f /etc/udhcpd.ivr.conf >> /tmp/udhcpd.log &
  fi


# Setup success message
cp /usr/lib/asterisk/sounds/success.gsm /usr/lib/asterisk/sounds/result.gsm
exit
