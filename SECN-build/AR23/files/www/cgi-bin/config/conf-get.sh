#!/bin/sh

# /www/cgi-bin/config/config-get.sh  
# This script gets the secn, network, dhcp and wireless configuration values
# then generates the config.html page file which will display the current configuration values.

# Get version string from banner
REV=`cat /etc/openwrt_version`
VERSION=`cat /etc/banner | grep Version`" "$REV

# Time
DATE=`date`
UPTIME=`uptime`
TZ=`cat /etc/TZ`

# Set DHCP subnet to current subnet for Softphone Support
/bin/setdhcpsubnet.sh > /dev/null

# Get the Asterisk and Access Point confg parameters 
# from config file /etc/config/secn


# Access Point configuration parameters
SSID=`uci get secn.accesspoint.ssid`
ENCRYPTION=`uci get secn.accesspoint.encryption`
WPA_KEY_MGMT=`uci get secn.accesspoint.wpa_key_mgmt`
PASSPHRASE=`uci get secn.accesspoint.passphrase`
AP_DISABLE=`uci get secn.accesspoint.ap_disable`
USREG_DOMAIN=`uci get secn.accesspoint.usreg_domain`
MAXASSOC=`uci get secn.accesspoint.maxassoc`

# Set AP Connections to show 'Disabled' if reqd.
if [ $MAXASSOC = "0" ]; then
  MAXASSOC="Disabled"
fi 

# DHCP configuration parameters
DHCP_ENABLE=`uci get secn.dhcp.enable`
DHCP_AUTH=`uci get secn.dhcp.dhcp_auth`
STARTIP=`uci get secn.dhcp.startip`
ENDIP=`uci get secn.dhcp.endip`
MAXLEASES=`uci get secn.dhcp.maxleases`
LEASETERM=`uci get secn.dhcp.leaseterm`
DOMAIN=`uci get secn.dhcp.domain`
OPTION_SUBNET=`uci get secn.dhcp.subnet`
OPTION_ROUTER=`uci get secn.dhcp.router`
OPTION_DNS=`uci get secn.dhcp.dns`
OPTION_DNS2=`uci get secn.dhcp.dns2`

# MPGW setting
MPGW=`uci get secn.mpgw.mode`

# Get network settings from /etc/config/network and wireless

# br_lan configuration parameters
BR_IPADDR=`uci get network.lan.ipaddr`
BR_DNS=`uci get network.lan.dns`
BR_GATEWAY=`uci get network.lan.gateway`
BR_NETMASK=`uci get network.lan.netmask`

# mesh_0 configuration parameters
ATH0_IPADDR=`uci get network.mesh_0.ipaddr`
ATH0_NETMASK=`uci get network.mesh_0.netmask`
ATH0_SSID=`uci get wireless.ah_0.ssid`
ATH0_BSSID=`uci get wireless.ah_0.bssid`

# Radio
CHANNEL=`uci get wireless.radio0.channel`
ATH0_TXPOWER=`uci get wireless.radio0.txpower`
RADIOMODE=`uci get wireless.radio0.hwmode`
CHANBW=`uci get wireless.radio0.chanbw`

if [ $RADIOMODE = "11ng" ]; then
	# Display 802.11N-G mode
	RADIOMODE="802.11N-G"
else
	RADIOMODE="802.11G"
fi

# Get web server parameters
AUTH=`uci get secn.http.auth`
LIMITIP=`uci get secn.http.limitip`
ENSSL=`uci get secn.http.enssl`

# Get WAN settings
WANPORT=`uci get secn.wan.wanport`
ETHWANMODE=`uci get secn.wan.ethwanmode`
WANIP=`uci get secn.wan.wanip`
WANGATEWAY=`uci get secn.wan.wangateway`
WANMASK=`uci get secn.wan.wanmask`
WANDNS=`uci get secn.wan.wandns`

WANSSID=`uci get secn.wan.wanssid`
WANENCR=`uci get secn.wan.wanencr`
WANPASS=`uci get secn.wan.wanpass`

# GatewayTest Status message
GATEWAY_STATUS=`cat /tmp/gatewaystatus.txt`

# Check if system password has been set
PWDSET=`uci get secn.http.pw_preset`
if [ $PWDSET = "0" ]; then
	echo "System password has not been set" > /tmp/passwordstatus.txt
fi

# Password status message
PASSWORD_STATUS=`cat /tmp/passwordstatus.txt`

# Clear password fields
PASSWORD1="\"\""
PASSWORD2="\"\""

# Generate the new config page
# Everything from here to EOF will be written to the temporary html page file
# The HTML is in config.html

source /www/cgi-bin/config/html/config.html

# Clear the dhcp and password status messages
rm /tmp/gatewaystatus.txt
rm /tmp/passwordstatus.txt

