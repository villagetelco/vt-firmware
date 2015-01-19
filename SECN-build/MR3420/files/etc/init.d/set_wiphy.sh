#!/bin/sh

# /etc/init.d/set_wi-phy.sh

# This script sets up wifi device phy assignments for Duo USB devices
# to ensure that the internal wifi is assigned to radio0 by its phy value.

# Check the phy assigned to the internal radio (eg AR9330).
# By default it is phy0 but may be assigned phy1 if Ralink USB device is present.
# Atheros USB devices do not change the phy setting for the internal wifi.

WIFI_DEVICE="AR928"   # Set this value to match the router's internal wifi id string in dmesg.

# Check dmesg for phy assignment
CHECK_PHY0=$(dmesg |grep $WIFI_INT |grep -c "phy0")
CHECK_PHY1=$(dmesg |grep $WIFI_INT |grep -c "phy1")

# If WIFI_INT is set to phy1
if [ $CHECK_PHY1 = "1" ]; then
        uci set wireless.radio0.phy="phy1"
        uci set wireless.radio1.phy="phy0"
        uci commit wireless

# If WIFI_INT is set to phy0
elif [ $CHECK_PHY0 = "1" ]; then
        uci set wireless.radio0.phy="phy0"
        uci set wireless.radio1.phy="phy1"
        uci commit wireless
fi

