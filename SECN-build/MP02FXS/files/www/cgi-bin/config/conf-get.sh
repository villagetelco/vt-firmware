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

# Get FXS params
FXS="dragino2-si3217x.mp02"
LINE_Z=`uci get $FXS.opermode`
TONEZONE=`uci get $FXS.tonezone | tr '[a-z]' '[A-Z]'`
RXGAIN=`uci get $FXS.rxgain`
TXGAIN=`uci get $FXS.txgain`
HOOKFLASH=`uci get $FXS.rxflash`

LEC_ENABLE=`uci get $FXS.echocan`
if [ $LEC_ENABLE = "1" ]; then
	LEC_ENABLE="checked"
else
	LEC_ENABLE="0"
fi

MWI_ENABLE=`uci get $FXS.mwi`
if [ $MWI_ENABLE = "1" ]; then
	MWI_ENABLE="checked"
else
	MWI_ENABLE="0"
fi

MAIL_ENABLE=`uci get $FXS.mailbox`
if [ $MAIL_ENABLE != "" ]; then                       
	MAIL_ENABLE="checked"                                 
fi                                                       

LCD_ENABLE=`uci get $FXS.signalling`
if [ $LCD_ENABLE = "ls" ]; then
	LCD_ENABLE="checked"
else
	LCD_ENABLE="0"
fi

# Access Point configuration parameters
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
DEVICE_IP=`uci get secn.dhcp.device_ip`

DNSFILTER_ENABLE=` uci get secn.dnsfilter.enable`
DNSFILTER_NAME=` uci get secn.dnsfilter.name`

# Display the appropriate DNS setting. ????
if [ $DNSFILTER_ENABLE = "checked" ]; then
OPTION_DNS=`uci get secn.dnsfilter.dns1`
OPTION_DNS2=`uci get secn.dnsfilter.dns2`
else
OPTION_DNS=`uci get secn.dhcp.dns`
OPTION_DNS2=`uci get secn.dhcp.dns2`
fi 

# Set up Mesh Enable
MESH_DISABLE=`uci get secn.mesh.mesh_disable`
if [ $MESH_DISABLE = "0" ]; then
	MESH_ENABLE="checked"
else
	MESH_ENABLE="0"
fi

# Mesh gateway setting
MPGW=`uci get secn.mesh.mpgw`

# Mesh Encryption
MESH_ENCR=`uci get secn.mesh.mesh_encr`
MESHPASSPHRASE=`uci get secn.mesh.mesh_passphrase`

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

# Radio
CHANNEL=`uci get wireless.radio0.channel`
ATH0_TXPOWER=`uci get wireless.radio0.txpower`
ATH0_TXPOWER_ACTUAL=`iwconfig | grep -A 2 'wlan0' | grep -m 1 'Tx-Power'| cut -d T -f 2|cut -d = -f 2`
RADIOMODE=`uci get wireless.radio0.htmode`
CHANBW=`uci get wireless.radio0.chanbw`
COUNTRY=`uci get wireless.radio0.country`
COVERAGE=`uci get wireless.radio0.coverage`

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

# LAN Port disable setting
LANPORT_DISABLE=`uci get secn.wan.lanport_disable`

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

