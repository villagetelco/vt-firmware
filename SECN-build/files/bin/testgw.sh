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
GWFLAG=`cat /tmp/gateway.txt | cut -d ' ' -f 1`
DNSFLAG=`cat /tmp/dns.txt | cut -d ' ' -f 1`

# For testing
#GW="192.168.1.254"
#DNS="192.168.1.254"

# Prepare status message
if [ $GWFLAG ]; then # Check for LAN gateway
  if [ $DNSFLAG ]; then
    GWTXT=" LAN DHCP: GW $GW  DNS $DNS  "
  else
    GWTXT=" LAN DHCP: GW $GW  " 
  fi
fi

# Add WAN setting message
WANPORT=`uci get secn.wan.wanport` 
WANTXT="  WAN Port: $WANPORT"

# Generate message string
echo $INTTXT $GWTXT $WANTXT > /tmp/gatewaystatus.txt

# Output message if script run manually for testing
#cat /tmp/gatewaystatus.txt


