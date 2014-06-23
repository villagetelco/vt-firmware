#!/bin/sh -x

# /etc/init.d/set-mesh-gw-mode.sh
# This script configures batman-adv correctly on startup
# It sets up bridge loop avoidance mode and mesh gateway mode on startup

# Add the adhoc interface
/usr/sbin/batctl if add wlan0-1 wlan1-1

# Enable Bridge Loop Avoidance mode
/usr/sbin/batctl bl 1
sleep 5

# Get the MPGW setting from /etc/config/secn
MPGW=`uci get secn.mesh.mpgw`

# Set up mesh gateway mode
if [ $MPGW = "OFF" ]; then
  /usr/sbin/batctl gw off
  uci set batman-adv.bat0.gw_mode=off
  fi

if [ $MPGW = "SERVER" ]; then
  /usr/sbin/batctl gw server
  uci set batman-adv.bat0.gw_mode=server
  fi

if [ $MPGW = "SERVER-1Mb" ]; then
  /usr/sbin/batctl gw server 1mbit
  uci set batman-adv.bat0.gw_mode='server 1mbit'
  fi

if [ $MPGW = "SERVER-2Mb" ]; then
  /usr/sbin/batctl gw server 2mbit
  uci set batman-adv.bat0.gw_mode='server 2mbit'
  fi

if [ $MPGW = "SERVER-5Mb" ]; then
  /usr/sbin/batctl gw server 5mbit
  uci set batman-adv.bat0.gw_mode='server 5mbit'
  fi

if [ $MPGW = "SERVER-10Mb" ]; then
  batctl gw server 10mbit
  uci set batman-adv.bat0.gw_mode='server 10mbit'
  fi

if [ $MPGW = "CLIENT" ]; then
  /usr/sbin/batctl gw client
  uci set batman-adv.bat0.gw_mode=client
  fi

uci commit batman-adv

# Add bat0 to bridge now that it is configured and bl is enabled
WANPORT=`uci get secn.wan.wanport`
ETHWANMODE=`uci get secn.wan.ethwanmode`

if [ $WANPORT = "Mesh" ]; then
	brctl addif br-wan bat0
	# Force udhcpc lease renewal
	if [ $ETHWANMODE = "DHCP" ]; then	
		kill -SIGUSR1 `cat /var/run/udhcpc-br-wan.pid`
	fi
else
	brctl addif br-lan bat0
fi

# Check to see if mesh AP isolation is required by either band.
AP_ISOL=`uci get secn.accesspoint.ap_isol`
AP_ISOL1=`uci get secn.accesspoint1.ap_isol`
MESH_ENABLE=`uci get secn.mesh.mesh_enable`
MESH_ENABLE1=`uci get secn.mesh1.mesh_enable`

if [ $AP_ISOL = "1" ] && [ $MESH_ENABLE = "checked" ] && [ $WANPORT != "Mesh" ]; then  
	batctl ap 1
elif [ $AP_ISOL1 = "1" ] && [ $MESH_ENABLE1 = "checked" ] && [ $WANPORT != "Mesh" ]; then  
	batctl ap 1
else
	batctl ap 0
fi

###
