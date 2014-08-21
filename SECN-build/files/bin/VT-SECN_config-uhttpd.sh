#!/bin/sh -x
# /bin/VT-SECN_config-asterisk.sh


# Set up web server security configuration

# Get checkbox values
AUTH=`uci get secn.http.auth`
LIMITIP=`uci get secn.http.limitip`
ENSSL=`uci get secn.http.enssl`

# Set up basic auth
if [ $AUTH = "checked" ]; then                          
  uci set uhttpd.main.config="/etc/http.conf"
else
  uci set uhttpd.main.config="/etc/http.conf.off"
fi


# Set up Restricted IP and SSL

if [ $LIMITIP != "checked" ] && [ $ENSSL != "checked" ]; then
  uci set uhttpd.main.listen_http="0.0.0.0:80"
  uci set uhttpd.main.listen_https=""

elif [ $LIMITIP = "checked" ] && [ $ENSSL != "checked" ]; then
  uci set uhttpd.main.listen_http="172.31.255.254:80"
  uci set uhttpd.main.listen_https=""

elif [ $LIMITIP != "checked" ] && [ $ENSSL = "checked" ]; then
      uci set uhttpd.main.listen_http=""                                                  
      uci set uhttpd.main.listen_https="0.0.0.0:443"

elif [ $LIMITIP = "checked" ] && [ $ENSSL = "checked" ]; then
    uci set uhttpd.main.listen_http=""
    uci set uhttpd.main.listen_https="172.31.255.254:443"
fi


# Save the changes 
uci commit uhttpd

sleep 1

#----------------------------------------------

