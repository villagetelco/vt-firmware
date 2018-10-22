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
DHCP_AUTH="0"
MESH_ENABLE="0"
MESH_ENABLE1="0"
AP_ENABLE="0"
AP_ENABLE1="0"
DEVICE_IP="0"
AP_ISOL="0"
AP_ISOL1="0"
COUNTRY=" "
COUNTRY1=" "
LANPORT_DISABLE="0"
DNSFILTER_ENABLE="0"

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
`echo $QUERY_STRING | cut -d \& -f 60`
`echo $QUERY_STRING | cut -d \& -f 61`
`echo $QUERY_STRING | cut -d \& -f 62`
`echo $QUERY_STRING | cut -d \& -f 63`
`echo $QUERY_STRING | cut -d \& -f 64`
`echo $QUERY_STRING | cut -d \& -f 65`
`echo $QUERY_STRING | cut -d \& -f 66`
`echo $QUERY_STRING | cut -d \& -f 67`
`echo $QUERY_STRING | cut -d \& -f 68`
`echo $QUERY_STRING | cut -d \& -f 69`
`echo $QUERY_STRING | cut -d \& -f 70`


# Refresh screen without saving 
if [ \$BUTTON = "Refresh" ]; then
	exit
fi

# Restore default config settings
if [ \$BUTTON = "Restore+Defaults" ]; then
	cd /etc
	tar -xzvf conf-default.tar.gz >> /dev/null
	cd
	/etc/init.d/config_secn > /dev/null  # Create new config files
	exit
fi

# Fix the handling of the 'hash' character
if [ \$DIALOUT = "%23" ]; then
	DIALOUT="#"
fi


# If Master softphone mode is selected, then make sure Asterisk is enabled 
if [ \$SOFTPH = "MASTER" ]; then
  ENABLE_AST="checked"
  fi

# If Enable SIP mode is selected, then make sure Asterisk is enabled 
if [ \$ENABLE = "checked" ]; then
  ENABLE_AST="checked"
  fi

# Check if Asterisk is installed and reset UI controls if not

AST_INSTALLED="`opkg list_installed | grep  'asterisk' | cut -d 'k' -f 1`k"

if [ \$AST_INSTALLED != "asterisk" ]; then
  SOFTPH="OFF"
  ENABLE_AST="0"
  ENABLE="0"
  fi

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

# Disable Mesh if required
if [ \$MESH_ENABLE = "checked" ]; then
	MESH_DISABLE="0"
else
	MESH_DISABLE="1"
fi

# Set up AP Isolation
if [ \$AP_ISOL = "checked" ]; then
	AP_ISOL="1"
else
	AP_ISOL="0"
fi

# Set MAXASSOC1 to null if display value 'Max' is returned
if [ \$MAXASSOC1 = "Max" ]; then
  MAXASSOC1=""
fi

# Disable AP1 if required
if [ \$AP_ENABLE1 = "checked" ]; then
	AP_DISABLE1="0"
else
	AP_DISABLE1="1"
fi

if [ \$AP_ISOL1 = "checked" ]; then
	AP_ISOL1="1"
else
	AP_ISOL1="0"
fi

# Disable Mesh1 if required
if [ \$MESH_ENABLE1 = "checked" ]; then
	MESH_DISABLE1="0"
else
	MESH_DISABLE1="1"
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
uci set network.mesh_1.ipaddr=\$ATH0_IPADDR1
uci set network.mesh_1.netmask=\$ATH0_NETMASK1

# Write the radio settings into /etc/config/wireless
uci set wireless.radio0.channel=\$CHANNEL
uci set wireless.radio0.txpower=\$ATH0_TXPOWER
uci set wireless.radio0.chanbw=\$CHANBW
uci set wireless.radio0.country=\$COUNTRY
uci set wireless.radio0.htmode=\$RADIOMODE
uci set wireless.radio0.coverage=\$COVERAGE

uci set wireless.radio1.country=\$COUNTRY1
uci set wireless.radio1.channel=\$CHANNEL1
uci set wireless.radio1.txpower=\$ATH0_TXPOWER1
uci set wireless.radio1.chanbw=\$CHANBW1
uci set wireless.radio1.htmode=\$RADIOMODE1
uci set wireless.radio1.coverage=\$COVERAGE1

# Set coverage now
/etc/init.d/set_coverage.sh

# Write the meshpoint interface settings into /etc/config/wireless
uci set wireless.ah_0.mesh_id=\MESH_ID
uci set wireless.ah_1.mesh_id=\MESH_ID1

# Write the Access Point wifi settings into /etc/config/secn
uci set secn.accesspoint.ssid=\$SSID
uci set secn.accesspoint.encryption=\$ENCRYPTION
uci set secn.accesspoint.passphrase=\$PASSPHRASE
uci set secn.accesspoint.maxassoc=\$MAXASSOC
uci set secn.accesspoint.ap_isol=\$AP_ISOL
uci set secn.accesspoint.ap_disable=\$AP_DISABLE

uci set secn.accesspoint1.ssid=\$SSID1
uci set secn.accesspoint1.encryption=\$ENCRYPTION1
uci set secn.accesspoint1.passphrase=\$PASSPHRASE1
uci set secn.accesspoint1.ap_disable=\$AP_DISABLE1
uci set secn.accesspoint1.maxassoc=\$MAXASSOC1
uci set secn.accesspoint1.ap_isol=\$AP_ISOL1

# Write the Asterisk settings into /etc/config/secn
uci set secn.asterisk.host=\$HOST
uci set secn.asterisk.reghost=\$REGHOST
uci set secn.asterisk.proxy=\$PROXY
uci set secn.asterisk.username=\$USER
uci set secn.asterisk.fromusername=\$USER
uci set secn.asterisk.enable=\$ENABLE
uci set secn.asterisk.enable_ast=\$ENABLE_AST
uci set secn.asterisk.register=\$REGISTER
uci set secn.asterisk.dialout=\$DIALOUT
uci set secn.asterisk.codec1=\$CODEC1
uci set secn.asterisk.codec2=\$CODEC2
uci set secn.asterisk.codec3=\$CODEC3
uci set secn.asterisk.externip=\$EXTERNIP
uci set secn.asterisk.enablenat=\$ENABLENAT
uci set secn.asterisk.softph=\$SOFTPH

if [ \$SECRET != "****" ]; then					# Set the password only if newly entered
	uci set secn.asterisk.secret=\$SECRET
fi

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

# Save DNS addresses only if DNS filter is not already enabled 
DNSFILTER_ENABLE_OLD=`uci get secn.dnsfilter.enable`
if [ \$DNSFILTER_ENABLE_OLD != "checked" ]; then
	uci set secn.dhcp.dns=\$OPTION_DNS
	uci set secn.dhcp.dns2=\$OPTION_DNS2
	uci set secn.dnsfilter.landns=\$BR_DNS
fi

# Save mesh settings to /etc/config/secn
uci set secn.mesh.mesh_disable=\$MESH_DISABLE
uci set secn.mesh1.mesh_disable=\$MESH_DISABLE1
uci set secn.mesh.mpgw=\$MPGW
##uci set secn.mesh.mesh_encr=\$MESH_ENCR
##uci set secn.mesh.mesh_passphrase=\$MESHPASSPHRASE
##uci set secn.mesh1.mesh_encr=\$MESH_ENCR1
##uci set secn.mesh1.mesh_passphrase=\$MESHPASSPHRASE1

# Save mesh settings to /etc/config/wireless
uci set wireless.ah0.mesh_id=\$MESH_ID
uci set wireless.ah1.mesh_id=\$MESH_ID   # Use same id for single batman instance
#uci set wireless.ah1.mesh_id=\$MESH_ID1

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

if [ \$BUTTON = "Restart+Asterisk" ]; then
  # Restart Asterisk
  /etc/init.d/asterisk restart > /dev/null &
  # Allow time to register
  sleep 5
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


