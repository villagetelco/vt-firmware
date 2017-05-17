#!/bin/sh -x
# /bin/config_secn_wifi.sh

# Set up WiFi 

# Get the params from uci config file /etc/config/secn and wireless
SSID=`uci get secn.accesspoint.ssid`
SSID=`echo "$SSID" | sed -f /bin/url-decode.sed`
uci set secn.accesspoint.ssid=$SSID

PASSPHRASE=`uci get secn.accesspoint.passphrase`
PASSPHRASE=`echo "$PASSPHRASE" | sed -f /bin/url-decode.sed`
uci set secn.accesspoint.passphrase=$PASSPHRASE

ENCRYPTION=`uci get secn.accesspoint.encryption`
AP_ISOL=`uci get secn.accesspoint.ap_isol`
MAXASSOC=`uci get secn.accesspoint.maxassoc`
CHANNEL=`uci get wireless.radio0.channel`
AP_DISABLE=`uci get secn.accesspoint.ap_disable`
MESH_DISABLE=`uci get secn.mesh.mesh_disable`

# Set to WPA2 by default                                 
ENCRYPT="psk2"

if [ $ENCRYPTION = "WPA-WPA2-AES" ]; then                                   
ENCRYPT="mixed-psk+tkip+aes"
elif [ $ENCRYPTION = "WPA-WPA2" ]; then                          
ENCRYPT="mixed-psk"                                                     
elif [ $ENCRYPTION = "WPA2" ]; then                          
ENCRYPT="psk2"                                                      
elif [ $ENCRYPTION = "WPA" ]; then                                   
ENCRYPT="psk"
elif [ $ENCRYPTION = "WEP" ]; then                          
ENCRYPT="wep"                                                     
elif [ $ENCRYPTION = "NONE" ]; then                          
ENCRYPT="none"                                                      
fi

# Set up mesh encryption
MESH_ENCR=`uci get secn.mesh.mesh_encr`
MESHPASSPHRASE=`uci get secn.mesh.mesh_passphrase`

# Set to OFF by default                                 
MESH_ENCRYPT="off"

if [ $MESH_ENCR = "WPA2-AES" ]; then
MESH_ENCRYPT="psk2+aes"
elif [ $MESH_ENCR = "WPA2" ]; then
MESH_ENCRYPT="psk2"
fi

uci set wireless.ap_0.key=$PASSPHRASE
uci set wireless.ap_0.ssid=$SSID
uci set wireless.ap_0.mode="ap"
uci set wireless.ap_0.disabled=$AP_DISABLE
uci set wireless.ap_0.encryption=$ENCRYPT
uci set wireless.ap_0.maxassoc=$MAXASSOC
uci set wireless.ap_0.isolate=$AP_ISOL
uci set wireless.ah_0.disabled=$MESH_DISABLE
uci set wireless.ah_0.encryption=$MESH_ENCRYPT
########uci set wireless.ah_0.key=$MESHPASSPHRASE

# Setup AP Isolation on mesh unless it is used for WAN
WANPORT=`uci get secn.wan.wanport`

if [ $AP_ISOL = "1" ] && [ $WANPORT != "Mesh" ]; then  
	batctl ap 1
else
	batctl ap 0
fi


#----------------------------------------------
# Save the changes 
uci commit wireless
uci commit secn
sleep 1
