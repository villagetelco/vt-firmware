#!/bin/sh

CLASS=`uci get olpc.setup.class`
MODE=`uci get olpc.setup.mode`

HOST="CR"$CLASS

# Set the host name if Slave
if [ $MODE = "Slave-1" ];then
  HOST=$HOST"SL1"
elif [ $MODE = "Slave-2" ];then
  HOST=$HOST"SL2"
elif [ $MODE = "Slave-3" ];then
  HOST=$HOST"SL3"
fi

# Add Slaves to /etc/hosts
OCTET123=`uci get network.lan.ipaddr | cut -d = -f 2 | cut -d . -f 1,2,3`
echo "127.0.0.1 localhost"                    >  /etc/hosts
echo $OCTET123".254"" CR"$CLASS      >> /etc/hosts
echo $OCTET123".241"" CR"$CLASS"SL1" >> /etc/hosts
echo $OCTET123".242"" CR"$CLASS"SL2" >> /etc/hosts
echo $OCTET123".243"" CR"$CLASS"SL3" >> /etc/hosts
echo $OCTET123".254"" jabber"        >> /etc/hosts

# Set the hostname
uci set system.@system[0].hostname=$HOST
uci commit system

# Set the hostname as the Common Name in the SSL certificate for the web server.
uci set uhttpd.px5g.commonname=$HOST
uci commit uhttpd

# Set the system hostname
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname


