#!/bin/ash 

{
# Check wireless type
RADIO=`uci get wireless.radio0.type`
if [ $RADIO = "atheros" ]; then 
  WIRELESS="ath"  # atheros
else
	WIRELESS="wlan" # mac80211
fi

# Enable RACHEL logging if required: set to "1"
LOGGING="0"

# Set up symbolic links to txt files from /www
touch /tmp/mesh.txt
ln -s /tmp/mesh.txt /www/mesh.txt
touch /tmp/wifi.txt
ln -s /tmp/wifi.txt /www/wifi.txt
touch /tmp/bat1.txt
ln -s /tmp/bat1.txt /www/bat1.txt
touch /tmp/bat2.txt
ln -s /tmp/bat2.txt /www/bat2.txt
touch /tmp/stat.txt
ln -s /tmp/stat.txt /www/stat.txt

# Generate the txt files every 10 seconds
# Get batman-adv info
while (true); do \

batctl o > /tmp/bat1 &&\
batctl gwl > /tmp/bat2 

mv  /tmp/bat1  /tmp/bat1.txt &&\
mv /tmp/bat2   /tmp/bat2.txt

# Status iframe
UPTIME=`uptime`
PROC=`ps|wc -l`
MEMFREE=`cat /proc/meminfo | grep MemFree |cut -d : -f2 | tr -d ' '|tr -d 'kB'`
MEMTOT=`cat /proc/meminfo | grep MemTotal |cut -d : -f2 | tr -d ' '`
echo "Time: $UPTIME  CPU Processes: $PROC  Free/Total Memory: $MEMFREE" / "$MEMTOT" > /tmp/stat.txt 

# Check whether mesh adhoc or sta mode
STA_MODE=`iwconfig|grep -c $WIRELESS"0-2"`

if [ $STA_MODE = "0" ]; then 
	# Get mesh adhoc association details
	echo "Station MAC Addr     Signal    2.4GHz"  > /tmp/mesh.txt
	iwinfo $WIRELESS'0-1' assoclist              >> /tmp/mesh.txt
else
	# Get sta connection details
	echo "Host AP"                                > /tmp/mesh.txt
	echo "Station MAC Addr     Signal    2.4GHz" >> /tmp/mesh.txt
	iwinfo $WIRELESS'0-2' assoclist              >> /tmp/mesh.txt
fi

# Get AP association details
echo "Number of connected clients: "`iwinfo $WIRELESS"0" assoclist | grep -c SNR` > /tmp/wifi.txt
echo "Station MAC Addr     Signal    2.4Ghz"                              >> /tmp/wifi.txt
iwinfo $WIRELESS'0' assoclist                                             >> /tmp/wifi.txt

# Generate log entry
if [ $LOGGING = "1" ]; then
	UPTIME=`uptime`
	COUNT=`iwinfo $WIRELESS"0" assoclist | grep -c SNR`
	MEMFREE=`cat /proc/meminfo | grep MemFree |cut -d : -f2 | tr -d ' '|tr -d 'kB'`
	MEMTOT=`cat /proc/meminfo | grep MemTotal |cut -d : -f2 | tr -d ' '`
	echo "Connections: "$COUNT "Time: "$UPTIME " Mem Free / Tot: "$MEMFREE" / "$MEMTOT >> /www/rachel/logs/log.txt
	sleep 60; \
else
	sleep 10; \
fi

done &
} >/dev/null 2>&1    # dump unwanted output to avoid filling log
