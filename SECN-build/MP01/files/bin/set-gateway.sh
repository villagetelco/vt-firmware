#!/bin/sh

# /bin/set-gateway.sh
# This script is called from Asterisk IVR GATE set gateway code

# Get gateway octet from temp file created by asterisk
GWOCTET=`cat /tmp/gw-octet.txt`

# If the code is 999 find the gateway automatically
if [ $GWOCTET = "999" ]; then

GW=`uci get network.lan.ipaddr | awk -F. '{print $1"."$2"."$3"."001}'`
TESTGW1=`uci get network.lan.ipaddr | awk -F. '{print $1"."$2"."$3"."1}'`
TESTGW2=`uci get network.lan.ipaddr | awk -F. '{print $1"."$2"."$3"."254}'`

	if ping -c 1 $TESTGW1 >> /dev/null 
	   then                           
	   GW=$TESTGW1
	   else
	     if  ping -c 1 $TESTGW2 >> /dev/null 
	         then
	         GW=$TESTGW2
	     fi
	fi

# Save the Gateway address
uci set network.lan.gateway=$GW
uci commit network

exit
fi

# Test for valid address and exit if too large
if [ $GWOCTET -gt "254" ]; then
	exit
fi

# Build the gateway IP from MP address and gw octet
GW=`uci get network.lan.ipaddr | awk -F. '{print $1"."$2"."$3}'`
GW1=`echo $GW"."$GWOCTET`

# Save the gateway IP address
uci set network.lan.gateway=$GW1
uci commit network


