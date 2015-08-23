#!/bin/sh

# /bin/generate-extension.sh
# Generates lastoctet.extensions.conf include file for abbreviated dialling and echo test.

# Exit if Asterisk is not installed
if [ ! -d /etc/asterisk ]; then
	exit
fi 

# Get first three octets of IP address
OCTET123=`uci get network.lan.ipaddr | cut -d = -f 2 | cut -d . -f 1,2,3`

EXT="\${EXTEN}"
EXT4="\${EXTEN:4}"

# Create conf file
# Everything from here to EOF will be written to the file
cat > /etc/asterisk/lastoctet.extensions.conf << EOF
; This file is generated by the script /bin/generate-extension.sh
; Do not edit, this file will be automatically overwritten when you reboot the device.

; This section is for placing a call using 1,2 or 3 digit dialling of last octet of MPs IP address.
exten => _Z,1,Dial(SIP/4000@$OCTET123.$EXT)
exten => _0Z,1,Dial(SIP/4000@$OCTET123.$EXT)
exten => _00Z,1,Dial(SIP/4000@$OCTET123.$EXT)
exten => _ZX,1,Dial(SIP/4000@$OCTET123.$EXT)
exten => _0ZX,1,Dial(SIP/4000@$OCTET123.$EXT)
exten => _1XX,1,Dial(SIP/4000@$OCTET123.$EXT)
exten => _2[0-4]X,1,Dial(SIP/4000@$OCTET123.$EXT)
exten => _25[0-4],1,Dial(SIP/4000@$OCTET123.$EXT)

; This section is for the echo test 
exten => _3246X,1,SIPAddHeader(Alert-Info: Echo)
exten => _3246X,n,Dial(SIP/s@$OCTET123.$EXT4)
exten => _3246XX,1,SIPAddHeader(Alert-Info: Echo)
exten => _3246XX,n,Dial(SIP/s@$OCTET123.$EXT4)
exten => _3246XXX,1,SIPAddHeader(Alert-Info: Echo)
exten => _3246XXX,n,Dial(SIP/s@$OCTET123.$EXT4)

; End of file
EOF
