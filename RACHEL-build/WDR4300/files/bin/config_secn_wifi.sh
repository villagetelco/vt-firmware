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

uci set wireless.ap_0.key=$PASSPHRASE
uci set wireless.ap_0.ssid=$SSID
uci set wireless.ap_0.mode="ap"
uci set wireless.ap_0.disabled=$AP_DISABLE
uci set wireless.ap_0.encryption=$ENCRYPT
uci set wireless.ap_0.maxassoc=$MAXASSOC
uci set wireless.ap_0.isolate=$AP_ISOL
uci set wireless.ah_0.disabled=$MESH_DISABLE

#uci set wireless.ap_0.isolate=$AP_ISOL # AP isolation is on.

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

uci set wireless.ap_1.encryption=$ENCRYPT
uci set wireless.ap_1.key=$PASSPHRASE
uci set wireless.ap_1.ssid=$SSID
uci set wireless.ap_1.mode="ap"
uci set wireless.ap_1.disabled=$AP_DISABLE
uci set wireless.ap_1.maxassoc=$MAXASSOC
uci set wireless.ap_1.isolate=$AP_ISOL1
uci set wireless.ah_1.disabled=$MESH_DISABLE1

#uci set wireless.ap_1.isolate=$AP_ISOL # AP isolation is on.

# ----------------------------------
# Set up secondary AP on each band

# Get the params from uci config file /etc/config/secn and wireless
SSID2=`uci get secn.accesspoint2.ssid`
SSID2=`echo "$SSID2" | sed -f /bin/url-decode.sed`
uci set secn.accesspoint2.ssid=$SSID2

PASSPHRASE2=`uci get secn.accesspoint2.passphrase`
PASSPHRASE2=`echo "$PASSPHRASE2" | sed -f /bin/url-decode.sed`
uci set secn.accesspoint2.passphrase=$PASSPHRASE2

ENCRYPTION2=`uci get secn.accesspoint2.encryption`
MAXASSOC2=`uci get secn.accesspoint2.maxassoc`
AP_DISABLE2=`uci get secn.accesspoint2.ap_disable`

# Set to WPA2 by default                                 
ENCRYPT2="psk2"

if [ $ENCRYPTION2 = "WPA2" ]; then                          
ENCRYPT2="psk2"                                                      
elif [ $ENCRYPTION2 = "WPA" ]; then                                   
ENCRYPT2="psk"
elif [ $ENCRYPTION2 = "WEP" ]; then                          
ENCRYPT2="wep"                                                     
elif [ $ENCRYPTION2 = "NONE" ]; then                          
ENCRYPT2="none"                                                      
fi

# 2.4GHz
uci set wireless.ap_0_1.key=$PASSPHRASE2
uci set wireless.ap_0_1.ssid=$SSID2
uci set wireless.ap_0_1.mode="ap"
uci set wireless.ap_0_1.disabled=$AP_DISABLE2
uci set wireless.ap_0_1.encryption=$ENCRYPT2
uci set wireless.ap_0_1.maxassoc=$MAXASSOC2

#uci set wireless.ap_0_1.isolate=$AP_ISOL # AP isolation is on.

# 5GHz
uci set wireless.ap_1_1.key=$PASSPHRASE2
uci set wireless.ap_1_1.ssid=$SSID2
uci set wireless.ap_1_1.mode="ap"
uci set wireless.ap_1_1.disabled=$AP_DISABLE2
uci set wireless.ap_1_1.encryption=$ENCRYPT2
uci set wireless.ap_1_1.maxassoc=$MAXASSOC2

#uci set wireless.ap_1_1.isolate=$AP_ISOL # AP isolation is on.


# ---------------------------------
# Check to see if mesh AP isolation is required by either band.
WANPORT=`uci get secn.wan.wanport`

if [ $AP_ISOL = "1" ] && [ $MESH_DISABLE = "0" ] && [ $WANPORT != "Mesh" ]; then  
	batctl ap 1
elif [ $AP_ISOL1 = "1" ] && [ $MESH_DISABLE1 = "0" ] && [ $WANPORT != "Mesh" ]; then  
	batctl ap 1
else
	batctl ap 0
fi

# Set up mesh encryption
MESH_ENCR=`uci get secn.mesh.mesh_encr`
MESHPASSPHRASE=`uci get secn.mesh.mesh_passphrase`
MESH_ENCR1=`uci get secn.mesh1.mesh_encr`
MESHPASSPHRASE1=`uci get secn.mesh1.mesh_passphrase`

# Set to OFF by default                                 
MESH_ENCRYPT="off"
if [ $MESH_ENCR = "WPA2-AES" ]; then
MESH_ENCRYPT="psk2+aes"
elif [ $MESH_ENCR = "WPA2" ]; then
MESH_ENCRYPT="psk2"
fi

MESH_ENCRYPT1="off"
if [ $MESH_ENCR1 = "WPA2-AES" ]; then
MESH_ENCRYPT1="psk2+aes"
elif [ $MESH_ENCR1 = "WPA2" ]; then
MESH_ENCRYPT1="psk2"
fi

uci set wireless.ah_0.encryption=$MESH_ENCRYPT
uci set wireless.ah_1.encryption=$MESH_ENCRYPT1
uci set wireless.ah_0.key=$MESHPASSPHRASE
uci set wireless.ah_1.key=$MESHPASSPHRASE

#----------------------------------------------

# Save the changes 
uci commit wireless
uci commit secn

