#!/bin/sh -x
# /bin/VT-SECN_config-wan.sh

#Set up WAN Port

# Get WAN settings
WANPORT=`uci get secn.wan.wanport`
WANLAN_ENABLE=`uci get secn.wan.wanlan_enable`
ETHWANMODE=`uci get secn.wan.ethwanmode`
WANIP=`uci get secn.wan.wanip`
WANGATEWAY=`uci get secn.wan.wangateway`
WANMASK=`uci get secn.wan.wanmask`
WANDNS=`uci get secn.wan.wandns`
WANSSID=`uci get secn.wan.wanssid`
WANSSID=`echo "$WANSSID" | sed -f /bin/url-decode.sed`
uci set secn.wan.wanssid=$WANSSID
WANPASS=`uci get secn.wan.wanpass`
WANPASS=`echo "$WANPASS" | sed -f /bin/url-decode.sed`
uci set secn.wan.wanpass=$WANPASS

# Set up WAN wifi encryption 
WANENCRYPTION=`uci get secn.wan.wanencr`
# Set to WPA by default                                 
WANENCR="psk"

if [ $WANENCRYPTION = "WPA-WPA2-AES" ]; then                                   
	WANENCR="mixed-psk+tkip+aes"
elif [ $WANENCRYPTION = "WPA-WPA2" ]; then                          
	WANENCR="mixed-psk"
elif [ $WANENCRYPTION = "WPA2" ]; then                          
	WANENCR="psk2"
elif [ $WANENCRYPTION = "WPA" ]; then                                   
	WANENCR="psk"
elif [ $WANENCRYPTION = "WEP" ]; then                          
	WANENCR="wep"                                                     
elif [ $WANENCRYPTION = "NONE" ]; then                          
	WANENCR="none"                                                      
fi

# Get 3G USB modem params
SERVICE=`uci get secn.modem.service`
MODEMPORT=`uci get secn.modem.modemport`
APN=`uci get secn.modem.apn`
PIN=`uci get secn.modem.pin`

APNUSER=`uci get secn.modem.username`
APNUSER=`echo "$APNUSER" | sed -f /bin/url-decode.sed`
uci set secn.modem.username=$APNUSER

APNPW=`uci get secn.modem.password`
APNPW=`echo "$APNPW" | sed -f /bin/url-decode.sed`
uci set secn.modem.password=$APNPW

# Set up USBtty port string
TTY="/dev/ttyUSB"$MODEMPORT


# Set WAN wifi config
uci set wireless.sta_0.ssid=$WANSSID
uci set wireless.sta_0.key=$WANPASS
uci set wireless.sta_0.encryption=$WANENCR

# Clear WAN settings
uci set network.wan.ifname=''
uci set network.wan.proto=''
uci set network.wan.type=''
uci set network.wan.ipaddr=''
uci set network.wan.gateway=''
uci set network.wan.netmask=''
uci set network.wan.dns=''

uci set network.wan.service=''
uci set network.wan.apn=''
uci set network.wan.username=''
uci set network.wan.password=''
uci set network.wan.pin=''
uci set network.wan.device=''
uci set wireless.sta_0.disabled='1' # Make sure wifi WAN is off.

# Set default LAN port to eth0 and eth1 if 'WAN' port changed to LAN
if [ $WANLAN_ENABLE = "checked" ]; then
	uci set network.lan.ifname='eth0 eth1'
else
	uci set network.lan.ifname='eth0'
fi

# Set up for WAN disabled
if [ $WANPORT = "Disable" ]; then
	uci set wireless.ah_0.disabled='0'
	uci set wireless.sta_0.disabled='1'
fi

# Set up for Ethernet WAN
if [ $WANPORT = "Ethernet" ]; then
 	# Set up for Eth WAN port
	uci set network.lan.ifname='eth0'
	uci set network.lan.gateway='255.255.255.255'
	uci set network.wan.ifname='eth1'
	# Disable WAN port as LAN
	uci set secn.wan.wanlan_enable='0'
fi

# Set up for Mesh WAN
if [ $WANPORT = "Mesh" ]; then
 	# Set up eth1 as LAN or WAN
	if [ $WANLAN_ENABLE = "checked" ]; then
		uci set network.lan.ifname='eth0 eth1'
		uci set network.wan.ifname='bat0'
	else
		uci set network.lan.ifname='eth0'
		uci set network.wan.ifname='bat0 eth1' 
	fi
	uci set network.wan.type='bridge' # Reqd. See /etc/init.d/set-mesh-gw-mode
	MESH_ENABLE='checked'
	uci set secn.mesh.mesh_enable='checked'
	uci set network.lan.gateway='255.255.255.255'
fi

# Set up for WiFi WAN
if [ $WANPORT = "WiFi" ]; then
	uci set network.wan.ifname='wlan0-2'
	uci set wireless.ah_0.disabled='1'
	uci set wireless.sta_0.disabled='0'
	uci set network.lan.gateway='255.255.255.255'
	# Disable mesh
	uci set secn.mesh.mesh_enable='0'
	MESH_ENABLE='0'
fi

# Disable mesh if required
if [ $MESH_ENABLE = "checked" ]; then
	uci set wireless.ah_0.disabled='0'
else
	uci set wireless.ah_0.disabled='1'
fi

# Set up for DHCP or Static
if [ $ETHWANMODE = "Static" ]; then
	uci set network.wan.proto='static'
	uci set network.wan.ipaddr=$WANIP
	uci set network.wan.gateway=$WANGATEWAY
	uci set network.wan.netmask=$WANMASK
	uci set network.wan.dns=$WANDNS

else  # Set up for DHCP
	uci set network.wan.proto='dhcp'
	uci set network.wan.ipaddr=''
	uci set network.wan.gateway=''
	uci set network.wan.netmask=''
	uci set network.wan.dns=''
fi

# Set up for 3G Modem
# Note this must follow Static/DHCP test to ensure wan.proto is set to '3g'
if [ $WANPORT = "USB-Modem" ]; then
	uci set network.lan.gateway='255.255.255.255'
	uci set network.wan.ifname='ppp0'
	uci set network.wan.proto='3g'
	uci set network.wan.service=$SERVICE
	uci set network.wan.apn=$APN
	uci set network.wan.username=$APNUSER
	uci set network.wan.password=$APNPW
	uci set network.wan.pin=$PIN
	uci set network.wan.device=$TTY
fi

# Make sure firewall is enabled
/etc/init.d/firewall enable  

#-------------------------

# Save the changes 
uci commit network
uci commit wireless
uci commit secn

#-------------------------

