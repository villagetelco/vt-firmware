#!/bin/sh

# Test for Internet access 

ping -w 1 '8.8.8.8' > /dev/null; RETVAL=$?  

if [ $RETVAL -eq 0 ]; then
	INTTXT="Internet access available.   "
	INTACCESS='1'
else
	INTTXT="No Internet access.   "
fi


# Find network details with DHCP Discover request

# Set up a temp iface
ifconfig br-lan:99 1.1.1.1

# Look for a DHCP server and call the script to get and save the env variables
udhcpc -n -i br-lan:99 -s /bin/savedhcp.sh > /dev/null

# Get the udhcpc pid
PID=`ps|grep  udhcpc | grep br-lan:99 | cut -d ' ' -f 2`

# Remove the temp iface and kill udhcpc process
ifconfig br-lan:99 down
kill $PID

# Get the saved LAN Gateway and DNS addresses
GW=`cat /tmp/gateway.txt | grep .`
DNS=`cat /tmp/dns.txt | grep .`

# For testing
#GW="192.168.1.254"
#DNS="192.168.1.254"

# Prepare status message
if [ $GW ]; then # Check for LAN gateway
  if [ $DNS ]; then
    GWTXT=" LAN DHCP Server - GW: $GW  DNS: $DNS"
  else
    GWTXT=" LAN DHCP Server - GW: $GW" 
  fi
else   # Must be WAN
	if [ $INTACCESS ]; then
		WANIP=`ifconfig | grep -A 1 wan | grep inet | cut -d : -f 2 |cut -d ' ' -f 1` 
 		GWTXT="  WAN IP: $WANIP"
	fi
fi

# Generate message string
echo $INTTXT $GWTXT > /tmp/gatewaystatus.txt

# Output message if script run manually for testing
#cat /tmp/gatewaystatus.txt


