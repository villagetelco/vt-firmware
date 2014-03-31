
#!/bin/ash 

# Keep-alive ping script

{
PINGTIME=`uci get secn.mesh.pingtime`
PINGHOST=`uci get secn.mesh.pinghost`
GATEWAY=`uci get network.lan.gateway`
INTERNETHOST='8.8.8.8'

# Save pid
PID=`ps|grep 'keep-alive' | grep '.sh' | cut -d ' ' -f 2`
echo $PID > /var/run/keep-alive.pid

if [ $PINGTIME = "OFF" ]; then
	exit
fi

while (true); do 
	ping -c 1 -w 1 -W 1 $PINGHOST 
	ping -c 1 -w 1 -W 1 $GATEWAY 
#	ping -c 1 -w 1 -W 1 $INTERNETHOST 

sleep $PINGTIME;

done &

} >/dev/null 2>&1    # Dump output to avoid filling log


