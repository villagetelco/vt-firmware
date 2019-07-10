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

# Cache
CACHE_COUNT=`ls -lh /mnt/sda1/ | grep cache | sed -r "s'[[:blank:]]+','g" | cut -d ',' -f 2`
CACHE_SPACE=`df -h | grep sda1 | sed -r "s'[[:blank:]]+','g" | cut -d ',' -f 4`

# DNS Filter
DNSFILTER_ENABLE=` uci get secn.dnsfilter.enable`
DNSFILTER_NAME=` uci get secn.dnsfilter.name`

# LAN Port enable
LANPORT_DISABLE=`uci get secn.wan.lanport_disable`
if [ $LANPORT_DISABLE = "0" ]; then
	LANPORT_ENABLE="checked"
else
	LANPORT_ENABLE="0"
fi

# Get USB Modem status details
USBMODEM=`/bin/usbmodem.sh`
USBSERIAL=`ls /dev/ttyUSB*`
USBSTATUS=`ifconfig | grep -A 1 3g | grep "inet addr"`

# Get diplay params
IP=`uci get network.lan.ipaddr`
CHANNEL=`uci get wireless.radio0.channel`
WIFINAME=`uci get wireless.ap_0.ssid`
AP_CONNECTIONS=`iwinfo wlan0 assoclist | grep -c SNR`
WIFINAME3=`uci get wireless.ap_3.ssid`
AP_CONNECTIONS3=`iwinfo wlan0-3 assoclist | grep -c SNR`

# Get RACHEL parameters
CLASS=`uci get rachel.setup.class`
MODE=`uci get rachel.setup.mode`
ENUSBMODEM=`uci get rachel.setup.enusbmodem`

SSIDPREFIX=`uci get rachel.setup.ssidprefix`
SSID=`uci get rachel.setup.ssid`
PASSPHRASE=`uci get rachel.setup.passphrase`
MAXASSOC=`uci get rachel.setup.maxassoc`
ENCRYPTION=`uci get rachel.setup.encryption`
AP_ENABLE=`uci get rachel.setup.ap_enable`

SSIDPREFIX3=`uci get rachel.setup.ssidprefix3`
SSID3=`uci get rachel.setup.ssid3`
PASSPHRASE3=`uci get rachel.setup.passphrase3`
MAXASSOC3=`uci get rachel.setup.maxassoc3`
ENCRYPTION3=`uci get rachel.setup.encryption3`
AP_ENABLE3=`uci get rachel.setup.ap_enable3`

TOTALASSOC=`uci get rachel.setup.totalassoc`
TXPOWER=`uci get rachel.setup.txpower`
WANPORT=`uci get rachel.setup.wanport`
CACHE_ENABLE=`uci get rachel.setup.cache_enable`

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

source /www/cgi-bin/config/html/config-rachel.html

# Clear the dhcp and password status messages
rm /tmp/gatewaystatus.txt
rm /tmp/passwordstatus.txt

