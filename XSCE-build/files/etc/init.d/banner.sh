#!/bin/sh

# Create banner file with version info

# Get details
DESC=`cat /etc/openwrt_release | grep _DESCRIPTION | cut -d \" -f 2`
REV=`cat /etc/openwrt_release | grep REVISION | cut -d \" -f 2`
MACHINE=`cat /proc/cpuinfo | grep machine | awk '{print $4;}'`

cp /etc/banner.txt /etc/banner
echo $DESC $REV $MACHINE >> /etc/banner
echo "" >> /etc/banner
echo "Village Telco - Small Enterprise Campus Network" >> /etc/banner
echo "" >> /etc/banner
cat /etc/secn_version >> /etc/banner

 
