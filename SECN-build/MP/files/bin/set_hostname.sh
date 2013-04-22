#!/bin/sh

sleep 2

if brctl show |grep bat0 

then

OCTET_D=`uci show network.lan.ipaddr | cut -d = -f2 | cut -d . -f4`

else

OCTET_D=`uci show network.wifi0.ipaddr | cut -d = -f2 | cut -d . -f4`

fi

uci set system.@system[0].hostname=TP-$OCTET_D
uci commit system
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname


