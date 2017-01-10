#!/bin/sh -x
# /bin/config_secn_cache.sh

# Set up Proxy configs

OCTET123=`uci get network.lan.ipaddr | cut -d = -f 2 | cut -d . -f 1,2,3`
CACHE_ENABLE=`uci get rachel.setup.cache_enable`

# Adjust IP settings
uci delete tinyproxy.tinyproxy.Allow
uci add_list tinyproxy.tinyproxy.Allow=$OCTET123".0/24"
uci add_list tinyproxy.tinyproxy.Allow=172.31.255.253  #Fallback client IP

uci delete polipo.general.allowedClients
uci add_list polipo.general.allowedClients=$OCTET123".0/24"
uci add_list polipo.general.allowedClients=172.31.255.253  #Fallback client IP

# Enable cache
if [ $CACHE_ENABLE = "checked" ]; then
	/etc/init.d/tinyproxy enable
	/etc/init.d/polipo enable
else	
	/etc/init.d/tinyproxy disable
	/etc/init.d/polipo disable
fi

# Firewall proxy settings are in /etc/firewall.user

uci commit polipo
uci commit tinyproxy

# Make sure cache directory exists
if [ ! -d /mnt/sda1/cache ]; then
	mkdir /mnt/sda1/cache
fi

