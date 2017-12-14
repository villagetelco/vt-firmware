#!/bin/sh -x

# Add Meshpoint wifi interface to WAN/LAN bridge
WANPORT=`uci get secn.wan.wanport`
MESH_DISABLE=`uci get secn.mesh.mesh_disable`

if [ $WANPORT = "Mesh" ] && [ $MESH_DISABLE = "0" ]; then
  brctl delif br-lan wlan0-1
  brctl addif br-wan wlan0-1
elif [ $WANPORT != "Mesh" ] && [ $MESH_DISABLE = "0" ]; then
  brctl delif br-wan wlan0-1
  brctl addif br-lan wlan0-1
fi
if [ $MESH_DISABLE = "1" ]; then
  brctl delif br-lan wlan0-1
  brctl delif br-wan wlan0-1
fi

exit


