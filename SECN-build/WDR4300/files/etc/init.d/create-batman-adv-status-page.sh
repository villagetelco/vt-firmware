#!/bin/ash 

# Set up symbolic links to txt files from /www
touch /tmp/mesh.txt
ln -s /tmp/mesh.txt /www/mesh.txt
touch /tmp/wifi.txt
ln -s /tmp/wifi.txt /www/wifi.txt
touch /tmp/bat1.txt
ln -s /tmp/bat1.txt /www/bat1.txt
touch /tmp/bat2.txt
ln -s /tmp/bat2.txt /www/bat2.txt

# Generate the txt file every 10 seconds
while (true); do \
batctl o > /tmp/bat1 &&\
batctl gwl > /tmp/bat2 &&\
mv  /tmp/bat1  /tmp/bat1.txt
mv /tmp/bat2   /tmp/bat2.txt


echo "Station MAC Addr     Signal    2.4Ghz" > /tmp/mesh.txt
iwinfo wlan0-1 assoclist >> /tmp/mesh.txt
echo "Station MAC Addr     Signal    5Ghz" >> /tmp/mesh.txt
iwinfo wlan1-1 assoclist >> /tmp/mesh.txt

echo "Station MAC Addr     Signal    2.4Ghz" > /tmp/wifi.txt
iwinfo wlan0 assoclist >> /tmp/wifi.txt
echo "Station MAC Addr     Signal    5Ghz" >>  /tmp/wifi.txt
iwinfo wlan1 assoclist >> /tmp/wifi.txt

sleep 10; \
done &
