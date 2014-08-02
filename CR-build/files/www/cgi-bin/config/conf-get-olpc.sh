#!/bin/sh

# /www/cgi-bin/config/config-get-cr.sh  
# This script gets the configuration values
# then generates the config.html page file which displays the values.

# Get version string from banner
REV=`cat /etc/openwrt_version`
VERSION=`cat /etc/banner | grep Version`" "$REV

# Time
DATE=`date`
UPTIME=`uptime`
TZ=`cat /etc/TZ`

# Get USB Modem status details
USBMODEM=`/bin/usbmodem.sh`
USBSERIAL=`ls /dev/ttyUSB*`
USBSTATUS=`ifconfig | grep -A 1 3g | grep "inet addr"`

# Get diplay params
IP=`uci get network.lan.ipaddr`
CHANNEL=`uci get wireless.radio0.channel`
WIFINAME=`uci get wireless.ap_0.ssid`
AP_CONNECTIONS=`iwinfo wlan0 assoclist | grep -c SNR`

# Get CR parameters
CLASS=`uci get olpc.setup.class`
MODE=`uci get olpc.setup.mode`
ENUSBMODEM=`uci get olpc.setup.enusbmodem`
SSIDPREFIX=`uci get olpc.setup.ssidprefix`
SSID=`uci get olpc.setup.ssid`
PASSPHRASE=`uci get olpc.setup.passphrase`
MAXASSOC=`uci get secn.accesspoint.maxassoc`
TXPOWER=`uci get olpc.setup.txpower`
WANPORT=`uci get olpc.setup.wanport`

# Set AP Connections to show 'Disabled' if reqd.
if [ $MAXASSOC = "0" ]; then
  MAXASSOC="Disabled"
fi 

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

source /www/cgi-bin/config/html/config-olpc.html

# Clear the dhcp and password status messages
rm /tmp/gatewaystatus.txt
rm /tmp/passwordstatus.txt

