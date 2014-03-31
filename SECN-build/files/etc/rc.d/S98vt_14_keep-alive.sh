#!/bin/ash 
{
PINGTIME=`uci get secn.mesh.pingtime`
PINGHOST=`uci get secn.mesh.pinghost`

while (true); do \

ping -c 1 $PINGHOST \

sleep $PINGTIME; \

done &

} >/dev/null 2>&1    # dump unwanted output to avoid filling log

