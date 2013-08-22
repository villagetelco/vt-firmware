#!/usr/bin/haserl  --shell=/bin/ash
<% echo -en "content-type: text/html\r\n\r\n" %>

<div class="modal-body">
  <h4>Changes saved!</h4>
</div>
<%# Write TimeZone into /etc/TZ %>
<%#
echo $FORM_TZ > /etc/TZ
uci set system.@system[0].timezone=$FORM_TZ
%>

<%# Write br_lan network settings into /etc/config/network %>
<%
uci set working.lan.ipaddr=$FORM_BR_IPADDR
uci set working.lan.gateway=$FORM_BR_GATEWAY
%>

<%# Write the Access Point wifi and web server settings into /etc/config/secn %>
<%
uci set secn.accesspoint.ssid=$FORM_SSID
uci set working.accesspoint.passphrase=$FORM_PASSPHRASE
uci set working.http.limitip=$FORM_LIMITIP
uci set working.http.enssl=$FORM_ENSSL
%>

<%# Write the wireless channel into /etc/config/wireless %>
<%
uci set working.radio0.channel=$FORM_CHANNEL
%>

<%# Commit the settings into /etc/config/ files %>
<%
uci commit working

%>