#!/usr/bin/haserl  --shell=/bin/ash

<%# Write TimeZone into /etc/TZ %>
<%
echo $FORM_TZ > /etc/TZ
uci set system.@system[0].timezone=$FORM_TZ
%>

<%# Write br_lan network settings into /etc/config/network %>
<%
uci set network.lan.ipaddr=$FORM_BR_IPADDR
uci set network.lan.gateway=$FORM_BR_GATEWAY
%>

<%# Write the Access Point wifi settings into /etc/config/secn %>
<%
uci set secn.accesspoint.ssid=$FORM_SSID
uci set secn.accesspoint.passphrase=$FORM_PASSPHRASE
%>

<%# Write the wireless channel into /etc/config/wireless %>
<%
uci set wireless.radio0.channel=$FORM_CHANNEL
%>

<%# Save the web server settings %>
<%
uci set secn.http.limitip=$FORM_LIMITIP
uci set secn.http.enssl=$FORM_ENSSL
%>

<%# Commit the settings into /etc/config/ files %>
<%
uci commit secn
uci commit network
uci commit wireless
uci commit system
%>