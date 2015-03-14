#! /bin/sh

RPIMAC="b8:27"  # This is the first part of the MAC address for RPi devices 

# Wait for memory and RPi devices to be available
sleep 20

# ------------------------------
# Mount the RACHEL memory device in case auto mount did not work.
mount /dev/sda1  /mnt/sda1
mount /dev/sda2  /mnt/sda2

# Remove old links
rm /www/rachel/modules
rm /www/rachel/local
rm /www/rachel/logs

# Find modules directory and force link
# Check for RACHEL SD Card
if [ -e "/mnt/sda2/var/www/modules" ]; then    
ln -s -f /mnt/sda2/var/www/modules /www/rachel/modules
ln -s -f /mnt/sda2/var/www/local   /www/rachel/local
mkdir /mnt/sda2/var/www/logs
ln -s -f /mnt/sda2/var/www/logs    /www/rachel/logs
fi

# Check for RACHEL USB
if [ -e "/mnt/sda1/RACHEL/bin/www/modules" ]; then
ln -s -f /mnt/sda1/RACHEL/bin/www/modules /www/rachel/modules
ln -s -f /mnt/sda1/RACHEL/bin/www/local   /www/rachel/local
mkdir /mnt/sda1/RACHEL/bin/www/logs
ln -s -f /mnt/sda1/RACHEL/bin/www/logs    /www/rachel/logs
fi

# Check for VT USB
if [ -e "/mnt/sda1/modules" ]; then
ln -s -f /mnt/sda1/modules /www/rachel/modules
ln -s -f /mnt/sda1/local   /www/rachel/local
mkdir /mnt/sda1/logs
ln -s -f /mnt/sda1/logs    /www/rachel/logs
fi

# Set up logs
mv /www/rachel/logs/log4.txt  /www/rachel/logs/log5.txt
mv /www/rachel/logs/log3.txt  /www/rachel/logs/log4.txt
mv /www/rachel/logs/log2.txt  /www/rachel/logs/log3.txt
mv /www/rachel/logs/log1.txt  /www/rachel/logs/log2.txt
mv /www/rachel/logs/log.txt   /www/rachel/logs/log1.txt

echo "Start session" > /www/rachel/logs/log.txt

# -----------------------------
# Set up RPi host in /etc/hosts
# The RPi must have time to start up and get DHCP IP by this point.

# Find the IP address of the RPi device from the MAC address
RPI=`cat /proc/net/arp | grep $RPIMAC | cut -d " " -f 1`

# Replace the line in /etc/hosts for "rachelpi"
sed -i 's/.* rachelpi/'"$RPI"' rachelpi/'  /etc/hosts 

# Restart DNS
/etc/init.d/dnsmasq restart


