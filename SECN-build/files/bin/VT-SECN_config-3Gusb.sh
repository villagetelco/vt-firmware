#!/bin/sh -x
# /bin/VT-SECN_config-3Gusb.sh


# Set up 3G USB Modem
VENDOR=`uci get secn.modem.vendor`
PRODUCT=`uci get secn.modem.product`
# Create the new usb-serial file
rm /etc/modules.d/60-usb-serial
cat >> /etc/modules.d/60-usb-serial << EOF
usbserial vendor=0x$VENDOR product=0x$PRODUCT
EOF

# -----------------------

# Set up modem chat scripts
DIALSTR=`uci get secn.modem.dialstr`
DIALSTR=`echo "$DIALSTR" | sed -f /bin/url-decode.sed`
uci set secn.modem.dialstr=$DIALSTR

# Set up dialstring line
DIALSTR2='"ATD'$DIALSTR'"'
DIALSTR3='ATD'$DIALSTR''

# Create the new chatscript files
rm /etc/chatscripts/3g.chat

cat >> /etc/chatscripts/3g.chat << EOF

ABORT   BUSY
ABORT   'NO CARRIER'
ABORT   ERROR
REPORT  CONNECT
TIMEOUT 10
""      "AT&F"
OK      "ATE1"
OK      'AT+CGDCONT=1,"IP","\$USE_APN"'
SAY     "Calling UMTS/GPRS"
TIMEOUT 30
OK      $DIALSTR2
CONNECT ' '

EOF

rm /etc/chatscripts/evdo.chat
cat >> /etc/chatscripts/evdo.chat << EOF

# This is a simple chat script based on the one provided by Sierra Wireless
# for CDMA connections.
ABORT  	BUSY
ABORT 	'NO CARRIER'
ABORT   ERROR
ABORT 	'NO DIAL TONE'
ABORT 	'NO ANSWER'
ABORT 	DELAYED
REPORT	CONNECT
TIMEOUT	10
''      AT
OK      ATZ
SAY     'Calling CDMA/EVDO'
TIMEOUT 30
OK      $DIALSTR3
CONNECT ''

EOF

# --------------

# Save the changes 
uci commit secn

# --------------

