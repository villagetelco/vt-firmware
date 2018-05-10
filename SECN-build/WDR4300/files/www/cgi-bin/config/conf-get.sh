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
PROC=`ps|wc -l`
# Memory
MEMFREE=`cat /proc/meminfo | grep MemFree |cut -d : -f2 | tr -d ' '|tr -d 'kB'`
MEMTOT=`cat /proc/meminfo | grep MemTotal |cut -d : -f2 | tr -d ' '`
MEMSTR=$MEMFREE" / "$MEMTOT

#Get Softphone directory
/bin/get-softph.sh

# Get WAN IP
WANIPASSIGNED=`/bin/get-wanip.sh`

# Get USB Modem details
USBMODEM=`/bin/usbmodem.sh`
USBSERIAL=`ls /dev/ttyUSB*`
USBSTATUS=`ifconfig | grep -A 1 3g | grep "inet addr"`

# Set DHCP subnet to current subnet for Softphone Support
/bin/setdhcpsubnet.sh > /dev/null

# Get the Asterisk and Access Point confg parameters 
# from config file /etc/config/secn

# Asterisk configuration parameters
ENABLE=`uci get secn.asterisk.enable`
REGISTER=`uci get secn.asterisk.register`
HOST=`uci get secn.asterisk.host`
REGHOST=`uci get secn.asterisk.reghost`
#SECRET=`uci get secn.asterisk.secret` # Do not display secret
SECRET="****"
USERNAME=`uci get secn.asterisk.username`
DIALOUT=`uci get secn.asterisk.dialout`
CODEC1=`uci get secn.asterisk.codec1`
CODEC2=`uci get secn.asterisk.codec2`
CODEC3=`uci get secn.asterisk.codec3`
EXTERNIP=`uci get secn.asterisk.externip`
ENABLENAT=`uci get secn.asterisk.enablenat`
SOFTPH=`uci get secn.asterisk.softph`
ENABLE_AST=`uci get secn.asterisk.enable_ast`

# 2.4GHz Access Point configuration parameters
SSID=`uci get secn.accesspoint.ssid`
ENCRYPTION=`uci get secn.accesspoint.encryption`
WPA_KEY_MGMT=`uci get secn.accesspoint.wpa_key_mgmt`
PASSPHRASE=`uci get secn.accesspoint.passphrase`
AP_DISABLE=`uci get secn.accesspoint.ap_disable`
MAXASSOC=`uci get secn.accesspoint.maxassoc`
AP_ISOL=`uci get secn.accesspoint.ap_isol`

# Set up AP enable
if [ $AP_DISABLE = "0" ]; then
  AP_ENABLE="checked"
else
  AP_ENABLE="0"
fi 

# Set up AP Isolation
if [ $AP_ISOL = "1" ]; then
  AP_ISOL="checked"
else
  AP_ISOL="0"
fi 

# 5GHz Access Point configuration parameters
SSID1=`uci get secn.accesspoint1.ssid`
ENCRYPTION1=`uci get secn.accesspoint1.encryption`
WPA_KEY_MGMT1=`uci get secn.accesspoint1.wpa_key_mgmt`
PASSPHRASE1=`uci get secn.accesspoint1.passphrase`
AP_DISABLE1=`uci get secn.accesspoint1.ap_disable`
MAXASSOC1=`uci get secn.accesspoint1.maxassoc`
AP_ISOL1=`uci get secn.accesspoint1.ap_isol`

# Set up AP enable
if [ $AP_DISABLE1 = "0" ]; then
  AP_ENABLE1="checked"
else
  AP_ENABLE1="0"
fi 

# Set AP Connections to show 'Disabled' if reqd.
if [ $MAXASSOC1 = "0" ]; then
  MAXASSOC1="Disabled"
fi 

# Set up AP Isolation
if [ $AP_ISOL1 = "1" ]; then
  AP_ISOL1="checked"
else
  AP_ISOL1="0"
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
DEVICE_IP=`uci get secn.dhcp.device_ip`

# Set up Mesh Enable
MESH_DISABLE=`uci get secn.mesh.mesh_disable`
if [ $MESH_DISABLE = "0" ]; then
	MESH_ENABLE="checked"
else
	MESH_ENABLE="0"
fi

MESH_DISABLE1=`uci get secn.mesh1.mesh_disable`
if [ $MESH_DISABLE1 = "0" ]; then
	MESH_ENABLE1="checked"
else
	MESH_ENABLE1="0"
fi

# Mesh gateway setting
MPGW=`uci get secn.mesh.mpgw`
MPGW1=`uci get secn.mesh.mpgw` # Slave off mpgw setting

# Mesh Encryption
MESH_ENCR=`uci get secn.mesh.mesh_encr`
MESHPASSPHRASE=`uci get secn.mesh.mesh_passphrase`
MESH_ENCR1=`uci get secn.mesh1.mesh_encr`
MESHPASSPHRASE1=`uci get secn.mesh1.mesh_passphrase`

# Get network settings from /etc/config/network and wireless

# br_lan configuration parameters
BR_IPADDR=`uci get network.lan.ipaddr`
BR_DNS=`uci get network.lan.dns`
BR_GATEWAY=`uci get network.lan.gateway`
BR_NETMASK=`uci get network.lan.netmask`

# mesh_0 configuration parameters
ATH0_IPADDR=`uci get network.mesh_0.ipaddr`
ATH0_NETMASK=`uci get network.mesh_0.netmask`
MESH_ID=`uci get wireless.ah_0.mesh_id`

# mesh_1 configuration parameters
ATH0_IPADDR1=`uci get network.mesh_1.ipaddr`
ATH0_NETMASK1=`uci get network.mesh_1.netmask`
MESH_ID1=`uci get wireless.ah_1.mesh_id`
MESH_DISABLE1=`uci get secn.mesh1.mesh_disable`

# 2.4GHz Radio 
CHANNEL=`uci get wireless.radio0.channel`
ATH0_TXPOWER=`uci get wireless.radio0.txpower`
ATH0_TXPOWER_ACTUAL=`iwconfig | grep -A 2 'wlan0' | grep -m 1 'Tx-Power'| cut -d T -f 2|cut -d = -f 2`
RADIOMODE=`uci get wireless.radio0.htmode`
CHANBW=`uci get wireless.radio0.chanbw`
COUNTRY=`uci get wireless.radio0.country`

# 5GHz Radio
CHANNEL1=`uci get wireless.radio1.channel`
ATH0_TXPOWER1=`uci get wireless.radio1.txpower`
ATH0_TXPOWER1_ACTUAL=`iwconfig | grep -A 2 'wlan1' | grep -m 1 'Tx-Power'| cut -d T -f 2|cut -d = -f 2`
RADIOMODE1=`uci get wireless.radio1.htmode`
CHANBW1=`uci get wireless.radio1.chanbw`
COUNTRY1=`uci get wireless.radio1.country`

# Get web server parameters
AUTH=`uci get secn.http.auth`
LIMITIP=`uci get secn.http.limitip`
ENSSL=`uci get secn.http.enssl`

# Get Asterisk registration status
/bin/get-reg-status.sh
REG_STATUS=`cat /tmp/reg-status.txt | awk '{print $5;}'`
REG_ACCT=`cat /tmp/reg-status.txt | awk '{print $1 " - " $3;}'`
REGHOST_STATUS=`cat /tmp/reghost.txt`

if [ $REG_STATUS = "Registered" ]; then
	# Display Not Registered status
	REG_STATUS="Registered Acct "
else
	REG_STATUS="Not Registered. $REGHOST_STATUS"
fi

# Get WAN settings
WANPORT=`uci get secn.wan.wanport`
ETHWANMODE=`uci get secn.wan.ethwanmode`
WANLAN_ENABLE=`uci get secn.wan.wanlan_enable`
WANIP=`uci get secn.wan.wanip`
SECWANIP=`uci get secn.wan.secwanip`
WANGATEWAY=`uci get secn.wan.wangateway`
WANMASK=`uci get secn.wan.wanmask`
WANDNS=`uci get secn.wan.wandns`
PORT_FORWARD=`uci get secn.wan.port_forward`

WANSSID=`uci get secn.wan.wanssid`
WANENCR=`uci get secn.wan.wanencr`
WANPASS=`uci get secn.wan.wanpass`

CONNTRACKCOUNT=`cat /proc/sys/net/netfilter/nf_conntrack_count`
CONNTRACKMAX=`cat /proc/sys/net/nf_conntrack_max`

# Get 3G USB Modem
MODEM_ENABLE=`uci get secn.modem.enabled`
MODEMSERVICE=`uci get secn.modem.service`
VENDOR=`uci get secn.modem.vendor`
PRODUCT=`uci get secn.modem.product`
APN=`uci get secn.modem.apn`
DIALSTR=`uci get secn.modem.dialstr`
APNUSER=`uci get secn.modem.username`
APNPW=`uci get secn.modem.password`
MODEMPIN=`uci get secn.modem.pin`
MODEMPORT=`uci get secn.modem.modemport`
MODEMURL=`uci get secn.modem.url`


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

