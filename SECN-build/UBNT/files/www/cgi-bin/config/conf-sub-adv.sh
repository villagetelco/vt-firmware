#!/bin/sh -x

# /www/cgi-bin/config/config-sub-adv.sh
# This script saves the settings when the Advanced page is submitted

# Build the new script file
#---------------------------------------------------
cat > /tmp/conf-save-adv.sh << EOF

#!/bin/sh

# Clear settings for checkboxes and buttons
ENABLE="0"
REGISTER="0"
ENABLENAT="0"
BUTTON="0"
DHCP_ENABLE="0"
ENABLE_AST="0"
USREG_DOMAIN="0"
DHCP_AUTH="0"
MESH_ENABLE="0"
AP_ENABLE="0"
DEVICE_IP="0"
AP_ISOL="0"

# Get Field-Value pairs from QUERY_STRING environment variable
# set by the form GET action
# Cut into individual strings: Field=Value


`echo $QUERY_STRING | cut -d \& -f 1`
`echo $QUERY_STRING | cut -d \& -f 2`
`echo $QUERY_STRING | cut -d \& -f 3`
`echo $QUERY_STRING | cut -d \& -f 4`
`echo $QUERY_STRING | cut -d \& -f 5`
`echo $QUERY_STRING | cut -d \& -f 6`
`echo $QUERY_STRING | cut -d \& -f 7`
`echo $QUERY_STRING | cut -d \& -f 8`
`echo $QUERY_STRING | cut -d \& -f 9`
`echo $QUERY_STRING | cut -d \& -f 10`
`echo $QUERY_STRING | cut -d \& -f 11`
`echo $QUERY_STRING | cut -d \& -f 12`
`echo $QUERY_STRING | cut -d \& -f 13`
`echo $QUERY_STRING | cut -d \& -f 14`
`echo $QUERY_STRING | cut -d \& -f 15`
`echo $QUERY_STRING | cut -d \& -f 16`
`echo $QUERY_STRING | cut -d \& -f 17`
`echo $QUERY_STRING | cut -d \& -f 18`
`echo $QUERY_STRING | cut -d \& -f 19`
`echo $QUERY_STRING | cut -d \& -f 20`
`echo $QUERY_STRING | cut -d \& -f 21`
`echo $QUERY_STRING | cut -d \& -f 22`
`echo $QUERY_STRING | cut -d \& -f 23`
`echo $QUERY_STRING | cut -d \& -f 24`
`echo $QUERY_STRING | cut -d \& -f 25`
`echo $QUERY_STRING | cut -d \& -f 26`
`echo $QUERY_STRING | cut -d \& -f 27`
`echo $QUERY_STRING | cut -d \& -f 28`
`echo $QUERY_STRING | cut -d \& -f 29`
`echo $QUERY_STRING | cut -d \& -f 30`
`echo $QUERY_STRING | cut -d \& -f 31`
`echo $QUERY_STRING | cut -d \& -f 32`
`echo $QUERY_STRING | cut -d \& -f 33`
`echo $QUERY_STRING | cut -d \& -f 34`
`echo $QUERY_STRING | cut -d \& -f 35`
`echo $QUERY_STRING | cut -d \& -f 36`
`echo $QUERY_STRING | cut -d \& -f 37`
`echo $QUERY_STRING | cut -d \& -f 38`
`echo $QUERY_STRING | cut -d \& -f 39`
`echo $QUERY_STRING | cut -d \& -f 40`
`echo $QUERY_STRING | cut -d \& -f 41`
`echo $QUERY_STRING | cut -d \& -f 42`
`echo $QUERY_STRING | cut -d \& -f 43`
`echo $QUERY_STRING | cut -d \& -f 44`
`echo $QUERY_STRING | cut -d \& -f 45`
`echo $QUERY_STRING | cut -d \& -f 46`
`echo $QUERY_STRING | cut -d \& -f 47`
`echo $QUERY_STRING | cut -d \& -f 48`
`echo $QUERY_STRING | cut -d \& -f 49`
`echo $QUERY_STRING | cut -d \& -f 50`
`echo $QUERY_STRING | cut -d \& -f 51`
`echo $QUERY_STRING | cut -d \& -f 52`
`echo $QUERY_STRING | cut -d \& -f 53`
`echo $QUERY_STRING | cut -d \& -f 54`
`echo $QUERY_STRING | cut -d \& -f 55`
`echo $QUERY_STRING | cut -d \& -f 56`
`echo $QUERY_STRING | cut -d \& -f 57`
`echo $QUERY_STRING | cut -d \& -f 58`
`echo $QUERY_STRING | cut -d \& -f 59`
`echo $QUERY_STRING | cut -d \& -f 60`


# Refresh screen without saving 
if [ \$BUTTON = "Refresh" ]; then
	exit
fi

# Restore default config settings
if [ \$BUTTON = "Restore+Defaults" ]; then
	cd /etc/config
	tar -xzvf conf-default.tar.gz >> /dev/null
	cd
	/etc/init.d/config_secn > /dev/null  # Create new config files
	exit
fi

# Fix the handling of the 'hash' character
if [ \$DIALOUT = "%23" ]; then
	DIALOUT="#"
fi

# Fix ATH0_BSSID string colon characters - replace '%3A' with ':'
ATH0_BSSID=\$(echo \$ATH0_BSSID | sed -e s/%3A/:/g)

# Set MAXASSOC to null if display value 'Max' is returned
if [ \$MAXASSOC = "Max" ]; then
  MAXASSOC=""
fi

# Disable AP if required
if [ \$AP_ENABLE = "checked" ]; then
	AP_DISABLE="0"
else
	AP_DISABLE="1"
fi

# Set up AP Isolation
if [ \$AP_ISOL = "checked" ]; then
	AP_ISOL="1"
else
	AP_ISOL="0"
fi


# Write the Field values into the SECN config settings

# Write br_lan network settings into /etc/config/network
uci set network.lan.ipaddr=\$BR_IPADDR
uci set network.lan.dns=\$BR_DNS
uci set network.lan.gateway=\$BR_GATEWAY
uci set network.lan.netmask=\$BR_NETMASK

# Write the mesh wifi settings into /etc/config/network
uci set network.mesh_0.ipaddr=\$ATH0_IPADDR
uci set network.mesh_0.netmask=\$ATH0_NETMASK

# Write the radio settings into /etc/config/wireless
uci set wireless.radio0.country=\$ATH0_COUNTRY
uci set wireless.radio0.channel=\$CHANNEL
uci set wireless.radio0.txpower=\$ATH0_TXPOWER
uci set wireless.radio0.chanbw=\$CHANBW

# Set up radio0 hwmode
if [ \$RADIOMODE = "11ng" ]; then
  uci set wireless.radio0.hwmode="11ng"
else
  uci set wireless.radio0.hwmode="11g"
fi

uci set wireless.radio1.country=\$ATH0_COUNTRY1
uci set wireless.radio1.channel=\$CHANNEL1
uci set wireless.radio1.txpower=\$ATH0_TXPOWER1
uci set wireless.radio1.chanbw=\$CHANBW1

# Set up radio1 hwmode
if [ \$RADIOMODE1 = "11na" ]; then
  uci set wireless.radio1.hwmode="11na"
else
  uci set wireless.radio1.hwmode="11a"
fi


# Write the adhoc interface settings into /etc/config/wireless
uci set wireless.ah_0.ssid=\$ATH0_SSID
uci set wireless.ah_0.bssid=\$ATH0_BSSID

# Write the Access Point wifi settings into /etc/config/secn
uci set secn.accesspoint.ssid=\$SSID
uci set secn.accesspoint.encryption=\$ENCRYPTION
uci set secn.accesspoint.passphrase=\$PASSPHRASE
uci set secn.accesspoint.ap_disable=\$AP_DISABLE
uci set secn.accesspoint.usreg_domain=\$USREG_DOMAIN  
uci set secn.accesspoint.maxassoc=\$MAXASSOC
uci set secn.accesspoint.ap_isol=\$AP_ISOL

# Write the DHCP settings into /etc/config/secn
uci set secn.dhcp.enable=\$DHCP_ENABLE
uci set secn.dhcp.dhcp_auth=\$DHCP_AUTH
uci set secn.dhcp.startip=\$STARTIP
uci set secn.dhcp.endip=\$ENDIP
uci set secn.dhcp.maxleases=\$MAXLEASES
uci set secn.dhcp.leaseterm=\$LEASETERM
uci set secn.dhcp.domain=\$DOMAIN
uci set secn.dhcp.dns=\$OPTION_DNS
uci set secn.dhcp.subnet=\$OPTION_SUBNET
uci set secn.dhcp.router=\$OPTION_ROUTER
uci set secn.dhcp.dns=\$OPTION_DNS
uci set secn.dhcp.dns2=\$OPTION_DNS2
uci set secn.dhcp.device_ip=\$DEVICE_IP

# Save mesh settings to /etc/config/secn
uci set secn.mesh.mesh_enable=\$MESH_ENABLE
uci set secn.mesh.mpgw=\$MPGW

# Set up mesh gateway mode on the fly
if [ \$MPGW = "OFF" ]; then
  batctl gw off
  uci set batman-adv.bat0.gw_mode=off
  fi

if [ \$MPGW = "SERVER" ]; then
  batctl gw server
  uci set batman-adv.bat0.gw_mode=server
  fi

if [ \$MPGW = "SERVER-1Mb" ]; then
  batctl gw server 1mbit
  uci set batman-adv.bat0.gw_mode='server 1mbit'
  fi

if [ \$MPGW = "SERVER-2Mb" ]; then
  batctl gw server 2mbit
  uci set batman-adv.bat0.gw_mode='server 2mbit'
  fi

if [ \$MPGW = "SERVER-5Mb" ]; then
  batctl gw server 5mbit
  uci set batman-adv.bat0.gw_mode='server 5mbit'
  fi

if [ \$MPGW = "SERVER-10Mb" ]; then
  batctl gw server 10mbit
  uci set batman-adv.bat0.gw_mode='server 10mbit'
  fi

if [ \$MPGW = "CLIENT" ]; then
  batctl gw client
  uci set batman-adv.bat0.gw_mode=client
  fi

# Commit the settings into /etc/config/ files
uci commit secn
uci commit network
uci commit wireless
uci commit batman-adv

# Set DHCP subnet to current subnet 
/bin/setdhcpsubnet.sh > /dev/null

# Create new config files
/etc/init.d/config_secn > /dev/null
/etc/init.d/config_secn-2 > /dev/null
# Make sure file writing is complete
sleep 2

# Save and Reboot
if [ \$BUTTON = "Reboot" ]; then
  # Output the reboot screen
  echo -en "Content-type: text/html\r\n\r\n"
  cat /www/cgi-bin/config/html/reboot.html
	touch /tmp/reboot			# Set rebooting flag
  /sbin/reboot -d 10		# Reboot after delay
fi

EOF
#-------------------------------------------------

# Make the file executable and run it to update the config settings.
# Catch any error messages
chmod +x /tmp/conf-save-adv.sh   > /dev/null
/tmp/conf-save-adv.sh

# Check if rebooting
if [ -f /tmp/reboot ]; then
	exit
fi 

# Build the configuration screen and send it back to the browser.
/www/cgi-bin/secn-tabs

# Clean up temporary files
rm /tmp/conf-save-adv.sh        > /dev/null
rm /tmp/config.html             > /dev/null


