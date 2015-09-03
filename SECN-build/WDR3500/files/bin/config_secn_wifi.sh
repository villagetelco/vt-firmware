#!/bin/sh -x

# /bin/config_secn_wifi

# Set up 2.4GHz WiFi 

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

uci set wireless.vt_ap_0.key=$PASSPHRASE
uci set wireless.vt_ap_0.ssid=$SSID
uci set wireless.vt_ap_0.mode="ap"
uci set wireless.vt_ap_0.disabled=$AP_DISABLE
uci set wireless.vt_ap_0.encryption=$ENCRYPT
uci set wireless.vt_ap_0.maxassoc=$MAXASSOC
uci set wireless.vt_ap_0.isolate=$AP_ISOL
uci set wireless.vt_ah_0.disabled=$MESH_DISABLE


# ------------------------------------------------------------------

# Set up 5GHz WiFi 

# Get the params from uci config file /etc/config/secn and wireless
SSID=`uci get secn.accesspoint1.ssid`
SSID=`echo "$SSID" | sed -f /bin/url-decode.sed`
uci set secn.accesspoint1.ssid=$SSID

PASSPHRASE=`uci get secn.accesspoint1.passphrase`
PASSPHRASE=`echo "$PASSPHRASE" | sed -f /bin/url-decode.sed`
uci set secn.accesspoint1.passphrase=$PASSPHRASE

ENCRYPTION=`uci get secn.accesspoint1.encryption`
AP_DISABLE=`uci get secn.accesspoint1.ap_disable`
MAXASSOC=`uci get secn.accesspoint1.maxassoc`
CHANNEL=`uci get wireless.radio1.channel`
AP_ISOL1=`uci get secn.accesspoint1.ap_isol`
MESH_DISABLE1=`uci get secn.mesh1.mesh_disable`

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

uci set wireless.vt_ap_1.encryption=$ENCRYPT
uci set wireless.vt_ap_1.key=$PASSPHRASE
uci set wireless.vt_ap_1.ssid=$SSID
uci set wireless.vt_ap_1.mode="ap"
uci set wireless.vt_ap_1.disabled=$AP_DISABLE
uci set wireless.vt_ap_1.maxassoc=$MAXASSOC
uci set wireless.vt_ap_1.isolate=$AP_ISOL1
uci set wireless.vt_ah_1.disabled=$MESH_DISABLE1

# Check to see if mesh AP isolation is required by either band.
WANPORT=`uci get secn.wan.wanport`

if [ $AP_ISOL = "1" ] && [ $MESH_DISABLE = "0" ] && [ $WANPORT != "Mesh" ]; then  
	batctl ap 1
elif [ $AP_ISOL1 = "1" ] && [ $MESH_DISABLE1 = "0" ] && [ $WANPORT != "Mesh" ]; then  
	batctl ap 1
else
	batctl ap 0
fi

#----------------------------------------------

