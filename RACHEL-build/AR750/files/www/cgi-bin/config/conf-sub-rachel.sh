#!/bin/sh

# /www/cgi-bin/config/config-sub-olpc.sh
# This script saves the settings when the OLPC page is submitted

# Build the new script file
#---------------------------------------------------
cat > /tmp/conf-save.sh << EOF

#!/bin/sh

# Set default values for checkboxes and buttons

BUTTON="0"
AP_ENABLE="0"
AP_ENABLE3="0"
CACHE_ENABLE="0"
DNSFILTER_ENABLE="0"

# Get Field-Value pairs from QUERY_STRING enironment variable
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

# Get logged in user
USER=admin

# Change password, save the result, prepare status message, set web auth on.
rm /tmp/passwordstatus.txt
if [ \$BUTTON = "Set+Password" ]; then
	date > /tmp/setpassword.txt
	(echo \$PASSWORD1; sleep 1; echo \$PASSWORD2) | passwd \$USER >> /tmp/setpassword.txt
	cat /tmp/setpassword.txt | grep change > /tmp/passwordstatus.txt
	echo ". Reboot to activate web UI Authentication" >> /tmp/passwordstatus.txt
	uci set secn.http.pw_preset="1"
	uci set secn.http.auth="checked"
	uci commit secn
	exit
fi


# Write TimeZone into /etc/TZ
echo \$TZ > /etc/TZ
uci set system.@system[0].timezone=\$TZ
uci commit system

# Save settings
uci set rachel.setup.class=\$CLASS
uci set rachel.setup.mode=\$MODE

uci set rachel.setup.ssidprefix=\$SSIDPREFIX
uci set rachel.setup.ssid=\$SSID
uci set rachel.setup.passphrase=\$PASSPHRASE
uci set rachel.setup.encryption=\$ENCRYPTION
uci set rachel.setup.maxassoc=\$MAXASSOC
#uci set rachel.setup.ap_enable=\$AP_ENABLE

uci set rachel.setup.ssidprefix3=\$SSIDPREFIX3
uci set rachel.setup.ssid3=\$SSID3
uci set rachel.setup.passphrase3=\$PASSPHRASE3
uci set rachel.setup.encryption3=\$ENCRYPTION3
uci set rachel.setup.ap_enable3=\$AP_ENABLE3

uci set rachel.setup.totalassoc=\$TOTALASSOC
uci set rachel.setup.wanport=\$WANPORT
uci set rachel.setup.cache_enable=\$CACHE_ENABLE

# Set MAXASSOC to zero if display value 'Disabled' is returned
if [ \$MAXASSOC = "Disabled" ]; then
  MAXASSOC="0"
fi
if [ \$MAXASSOC = "Disabled" ]; then
  MAXASSOC="0"
fi

# Set Tx Power
uci set rachel.setup.txpower=\$TXPOWER

# Update the DNS Filter Enable setting
uci set secn.dnsfilter.enable=\$DNSFILTER_ENABLE 

# Commit the settings 
uci commit rachel
uci commit secn

# Create new config files
/etc/init.d/config_rachel > /dev/null
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


# Make the file executable and run it to update the config settings
# Catch any error messages
chmod +x /tmp/conf-save.sh     > /dev/null
/tmp/conf-save.sh

# Check if rebooting
if [ -f /tmp/reboot ]; then
	exit
fi 

# Build the configuration screen and send it back to the browser.
/www/cgi-bin/secn-rachel

# Clean up temporary files
###rm /tmp/conf-save.sh           > /dev/null
###rm /tmp/config.html            > /dev/null

