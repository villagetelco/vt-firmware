#!/bin/sh -x
# /bin/config_secn_dhcp.sh


# Set up DHCP server
# Get the DHCP parameters from uci config file /etc/config/secn
DHCP_ENABLE=`uci get secn.dhcp.enable`
DHCP_AUTH_CHK=`uci get secn.dhcp.dhcp_auth`

if [ $DHCP_AUTH_CHK = "checked" ]; then
  DHCP_AUTH='1'
else
  DHCP_AUTH='0'
fi

STARTIP=`uci get secn.dhcp.startip | cut -d = -f 2 | cut -d . -f 4`
ENDIP=`uci get secn.dhcp.endip | cut -d = -f 2 | cut -d . -f 4`
LIMIT=$((ENDIP - STARTIP))

MAXLEASES=`uci get secn.dhcp.maxleases`
LEASETERM=`uci get secn.dhcp.leaseterm`
LEASETERM=$((LEASETERM / 60))'m'
DOMAIN=`uci get secn.dhcp.domain`
OPTION_DNS=`uci get secn.dhcp.dns`
OPTION_DNS2=`uci get secn.dhcp.dns2`
OPTION_SUBNET=`uci get secn.dhcp.subnet`
OPTION_ROUTER=`uci get secn.dhcp.router`

uci set dhcp.setup.dhcpleasemax=$MAXLEASES
uci set dhcp.setup.domain=$DOMAIN
uci set dhcp.setup.authoritative=$DHCP_AUTH

uci set dhcp.lan.start=$STARTIP
uci set dhcp.lan.limit=$LIMIT
uci set dhcp.lan.leasetime=$LEASETERM
uci set dhcp.lan.dhcp_option="1,$OPTION_SUBNET  3,$OPTION_ROUTER  6,$OPTION_DNS,$OPTION_DNS2"

#---------------------------------------------

# Save the changes 
uci commit dhcp
