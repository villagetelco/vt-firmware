#! /bin/sh
# /bin/get-wanip.sh

# Set up WAN Interface
WANPORT=`uci get secn.wan.wanport`

if [ $WANPORT = "Mesh" ]; then
	WANIF="br-wan"
elif [ $WANPORT = "Ethernet" ]; then
	WANIF="eth1"
elif [ $WANPORT = "WiFi" ]; then
	WANIF="wlan0-2"
elif [ $WANPORT = "USB-Modem" ]; then
	WANIF="wan"
elif [ $WANPORT = "USB-Eth-Modem" ]; then
	WANIF="eth2"
else
	exit
fi

# Get the assigned WAN Primary IP from ifconfig
WANIP=`ifconfig | grep -m 1 -A 2 $WANIF | grep inet | cut -d : -f 2 | cut -d " " -f 1`

echo $WANIP


