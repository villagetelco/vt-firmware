#!/bin/ash 
{
WIRELESS="wlan"

# Set up symbolic links to txt files from /www
touch /tmp/mesh.txt
ln -s /tmp/mesh.txt /www/mesh.txt
touch /tmp/wifi.txt
ln -s /tmp/wifi.txt /www/wifi.txt
touch /tmp/bat1.txt
ln -s /tmp/bat1.txt /www/bat1.txt
touch /tmp/bat2.txt
ln -s /tmp/bat2.txt /www/bat2.txt

# Generate the txt files every 10 seconds
# Get batman-adv info
while (true); do \
batctl o > /tmp/bat1 &&\
batctl gwl > /tmp/bat2 &&\
mv  /tmp/bat1  /tmp/bat1.txt
mv /tmp/bat2   /tmp/bat2.txt

# Check whether operating mesh adhoc or sta mode
STA_MODE=`iwconfig|grep -c wlan0-2`

if [ $STA_MODE = "0" ]; then 
# Get mesh adhoc association details
echo "Station MAC Addr     Signal    2.4Ghz"  > /tmp/mesh.txt
iwinfo $WIRELESS'0-1' assoclist              >> /tmp/mesh.txt
else
# Get sta connection details
echo "Host AP 2.4GHz"                         > /tmp/mesh.txt
echo "Station MAC Addr     Signal"           >> /tmp/mesh.txt
iwinfo $WIRELESS'0-2' assoclist              >> /tmp/mesh.txt
fi

STA_MODE1=`iwconfig|grep -c $WIRELESS"1-2"`

if [ $STA_MODE1 = "0" ]; then 
# Get mesh adhoc association details
echo "Station MAC Addr     Signal    5Ghz"   >> /tmp/mesh.txt
iwinfo $WIRELESS'1-1' assoclist              >> /tmp/mesh.txt
else
# Get sta connection details
echo "Host AP 5GHz"                          >> /tmp/mesh.txt
echo "Station MAC Addr     Signal"           >> /tmp/mesh.txt
iwinfo $WIRELESS'1-2' assoclist              >> /tmp/mesh.txt
fi

# Get AP association details
echo "Number of connected clients 2.4GHz AP: "`iwinfo $WIRELESS"0" assoclist | grep -c SNR` > /tmp/wifi.txt
echo "Station MAC Addr     Signal "                 >> /tmp/wifi.txt
iwinfo wlan0 assoclist                              >> /tmp/wifi.txt
echo "Number of connected clients   5Ghz AP: "`iwinfo $WIRELESS"0" assoclist | grep -c SNR` >> /tmp/wifi.txt
echo "Station MAC Addr     Signal "                 >>  /tmp/wifi.txt
iwinfo wlan1 assoclist                              >> /tmp/wifi.txt

sleep 10; \
done &
} >/dev/null 2>&1    # dump unwanted output to avoid filling log

