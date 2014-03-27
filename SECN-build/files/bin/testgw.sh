#!/bin/sh

# Test for Internet access 

ping -w 1 '8.8.8.8' > /dev/null; RETVAL=$?  

if [ $RETVAL -eq 0 ]; then
	INTTXT="Internet access available.   "
else
	INTTXT="No Internet access.   "
fi


# Find network details with DHCP Discover request

# Set up a temp iface
ifconfig br-lan:99 1.1.1.1

# Look for a DHCP server and call the script to get and save the env variables
udhcpc -n -i br-lan:99 -s /bin/savedhcp.sh > /dev/null

# Remove the temp iface
ifconfig br-lan:99 down

# Get the saved LAN Gateway and DNS addresses
GW=`cat /tmp/gateway.txt | grep .`
DNS=`cat /tmp/dns.txt | grep .`

# For testing
#GW="192.168.1.254"
#DNS="192.168.1.254"

# If no Gateway found, prepare status message text and set to 0.0.0.0
if [ $GW ]; then
  if [ $DNS ]; then
    GWTXT=" LAN DHCP Server - LAN Gateway: "$GW" DNS: "$DNS
  else
    GWTXT=" LAN DHCP Server - LAN Gateway: "$GW 
  fi
else
  GW="0.0.0.0"
  #GWTXT=" No LAN Gateway found"
fi

# Generate message string
echo $INTTXT $GWTXT > /tmp/gatewaystatus.txt

# Output message if script run manually for testing
#cat /tmp/gatewaystatus.txt

# Save the Gateway address if reqd
#uci set network.lan.gateway=$GW
#uci commit network

