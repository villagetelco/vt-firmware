#!/bin/sh -x

# /www/cgi-bin/config/config-sub-adv2.sh
# This script saves the settings when the Advanced2 page is submitted

# Build the new script file
#---------------------------------------------------
cat > /tmp/conf-save-adv2.sh << EOF

#!/bin/sh

# Clear settings for checkboxes and buttons
ENABLE="0"
REGISTER="0"
ENABLENAT="0"
BUTTON="0"
DHCP_ENABLE="0"
ENABLE_AST="0"
USREG_DOMAIN="0"
DHCP_AUTH='0'


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


# Refresh screen without saving 
if [ \$BUTTON = "Refresh" ]; then
	exit
fi

# Write the WAN settings
uci set secn.wan.wanport=\$WANPORT
uci set secn.wan.ethwanmode=\$ETHWANMODE
uci set secn.wan.wanip=\$WANIP
uci set secn.wan.wangateway=\$WANGATEWAY
uci set secn.wan.wanmask=\$WANMASK
uci set secn.wan.wandns=\$WANDNS

# WiFi WAN settings
uci set secn.wan.wanssid=\$WANSSID
uci set secn.wan.wanencr=\$WANENCR
uci set secn.wan.wanpass=\$WANPASS

# Write 3G USB modem settings
uci set secn.modem.enabled=\$MODEM_ENABLE
uci set secn.modem.vendor=\$VENDOR
uci set secn.modem.product=\$PRODUCT
uci set secn.modem.dialstr=\$DIALSTR
uci set secn.modem.modemport=\$MODEMPORT

uci set secn.modem.username=\$APNUSER
uci set secn.modem.password=\$APNPW
uci set secn.modem.pin=\$MODEMPIN
uci set secn.modem.service=\$MODEMSERVICE
uci set secn.modem.apn=\$APN

# Commit the settings into /etc/config/ files
uci commit secn


# Create new config files
/etc/init.d/config_secn > /dev/null
/etc/init.d/config_secn-2 > /dev/null
# Make sure file writing is complete
sleep 2

# Reboot
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
chmod +x /tmp/conf-save-adv2.sh   > /dev/null
/tmp/conf-save-adv2.sh

# Check if rebooting
if [ -f /tmp/reboot ]; then
	exit
fi 

# Build the configuration screen and send it back to the browser.
/www/cgi-bin/secn-tabs

# Clean up temporary files
rm /tmp/conf-save-adv2.sh        > /dev/null
rm /tmp/config.html             > /dev/null


