#!/usr/bin/haserl  --shell=/bin/ash
<% echo -en "content-type: text/html\r\n\r\n" %>

<div class="alert alert-success">
  <a class="close" data-dismiss="alert">&times;</a>
  <h4>Network changes saved.  Reboot for changes to take effect.</h4>
</div>
<%# Write TimeZone into /etc/TZ %>
<%#
echo $FORM_TZ > /etc/TZ
uci set system.@system[0].timezone=$FORM_TZ
%>

<%# Write br_lan network settings into /etc/config/network %>
<%
uci set network.lan.ipaddr=$FORM_BR_IPADDR
uci set network.lan.gateway=$FORM_BR_GATEWAY
%>

<%# Write the Access Point wifi and web server settings into /etc/config/secn %>
<%
uci set secn.accesspoint.ssid=$FORM_SSID
uci set secn.accesspoint.passphrase=$FORM_PASSPHRASE
uci set secn.http.limitip=$FORM_LIMITIP
uci set secn.http.enssl=$FORM_ENSSL
%>

<%# Write the wireless channel into /etc/config/wireless %>
<%
uci set wireless.radio0.channel=$FORM_CHANNEL
%>

<%# Write advanced settings %>
<%
uci set network.lan.dns=$FORM_BR_DNS
uci set network.lan.netmask=$FORM_BR_NETMASK
uci set network.mesh_0.ipaddr=$FORM_ATH0_IPADDR
uci set network.mesh_0.netmask=$FORM_ATH0_NETMASK
uci set wireless.radio0.country=$FORM_ATH0_COUNTRY
uci set wireless.radio0.txpower=$FORM_ATH0_TXPOWER
uci set wireless.radio0.hwmode=$FORM_RADIOMODE
uci set wireless.radio0.chanbw=$FORM_CHANBW
uci set wireless.ah_0.ssid=$FORM_ATH0_SSID
uci set wireless.ah_0.bssid=$FORM_ATH0_BSSID
uci set secn.accesspoint.encryption=$FORM_ENCRYPTION
uci set secn.accesspoint.ap_disable=$FORM_AP_DISABLE
uci set secn.accesspoint.usreg_domain=$FORM_USREG_DOMAIN  
uci set secn.accesspoint.maxassoc=$FORM_MAXASSOC
uci set secn.dhcp.enable=$FORM_DHCP_ENABLE
uci set secn.dhcp.dhcp_auth=$FORM_DHCP_AUTH
uci set secn.dhcp.startip=$FORM_STARTIP
uci set secn.dhcp.endip=$FORM_ENDIP
uci set secn.dhcp.maxleases=$FORM_MAXLEASES
uci set secn.dhcp.leaseterm=$FORM_LEASETERM
uci set secn.dhcp.domain=$FORM_DOMAIN
uci set secn.dhcp.dns=$FORM_OPTION_DNS
uci set secn.dhcp.subnet=$FORM_OPTION_SUBNET
uci set secn.dhcp.router=$FORM_OPTION_ROUTER
uci set secn.dhcp.dns=$FORM_OPTION_DNS
uci set secn.dhcp.dns2=$FORM_OPTION_DNS2
%>

<%# Commit the settings into /etc/config/ files %>
<%
uci commit secn
uci commit network
uci commit wireless
%>