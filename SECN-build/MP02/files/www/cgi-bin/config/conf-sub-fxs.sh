#!/bin/sh -x

# /www/cgi-bin/config/config-sub-fxs.sh
# This script saves the settings when the FXS page is submitted

# Build the new script file
#---------------------------------------------------
cat > /tmp/conf-save-fxs.sh << EOF

#!/bin/sh

# Clear settings for checkboxes and buttons
LCD_ENABLE='0'
LEC_ENABLE='0'
MWI_ENABLE='0'
MAIL_ENABLE='0'

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


# Refresh screen without saving 
if [ \$BUTTON = "Refresh" ]; then
	exit
fi

FXS="dragino2-si3217x.mp02"
MAILBOX="SECNProviderMailbox@SIP_Remote"

# Write the FXS settings
uci set \$FXS.opermode=\$LINE_Z
uci set \$FXS.rxgain=\$RXGAIN
uci set \$FXS.txgain=\$TXGAIN
uci set \$FXS.rxflash=\$HOOKFLASH

TONEZONE=\$(echo \$TONEZONE | tr '[A-Z]' '[a-z]')
uci set \$FXS.tonezone=\$TONEZONE

if [ \$LEC_ENABLE = "checked" ]; then    
uci set \$FXS.echocan="1"
else
uci set \$FXS.echocan="0"
fi

if [ \$MWI_ENABLE = "checked" ]; then    
uci set \$FXS.mwi="1"
else
uci set \$FXS.mwi="0"
fi

if [ \$LCD_ENABLE = "checked" ]; then
	uci set \$FXS.signalling="ls"
else
	uci set \$FXS.signalling="ks"
fi

if [ \$MAIL_ENABLE = "checked" ]; then    
	uci set \$FXS.mailbox="\$MAILBOX"         
else                                    
	uci set \$FXS.mailbox=""
fi                                               

# Commit the settings into /etc/config/ files
uci commit dragino2-si3217x

# Create new config files
/etc/init.d/config_secn > /dev/null
/etc/init.d/config_secn-2 > /dev/null
# Make sure file writing is complete
sleep 1

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
chmod +x /tmp/conf-save-fxs.sh   > /dev/null
/tmp/conf-save-fxs.sh

# Check if rebooting
if [ -f /tmp/reboot ]; then
	exit
fi 

# Build the configuration screen and send it back to the browser.
/www/cgi-bin/secn-tabs

# Clean up temporary files
rm /tmp/conf-save-fxs.sh        > /dev/null
rm /tmp/config.html             > /dev/null


