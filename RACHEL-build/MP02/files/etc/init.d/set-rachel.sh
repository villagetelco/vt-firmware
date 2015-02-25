#! /bin/sh

RPIMAC="b8:27"  # This is the first part of the MAC address for RPi devices 

# Wait for devices to be available
sleep 10

# ------------------------------
# Mount the RACHEL memory device in case auto mount doesn't work.
mount /dev/sda1  /mnt/sda1
mount /dev/sda2  /mnt/sda2

# Check for RACHEL SD Card
if [ -e "/mnt/sda2/var/www/modules" ]; then    
ln -s -f /mnt/sda2/var/www/modules /www/rachel/modules
fi

# Check for RACHEL USB
if [ -e "/mnt/sda1/RACHEL/bin/www/modules" ]; then
ln -s -f /mnt/sda1/RACHEL/bin/www/modules /www/rachel/modules
fi

# Check for VT USB
if [ -e "/mnt/sda1/modules" ]; then
ln -s -f /mnt/sda1/modules /www/rachel/modules
fi

# -----------------------------
# Set up RPi host in /etc/hosts
# The RPi must have time to start up and get DHCP IP by this point.

# Find the IP address of the RPi device from the MAC address
RPI=`cat /proc/net/arp | grep $RPIMAC | cut -d " " -f 1`

# Replace the line in /etc/hosts for "rachelpi"
sed -i 's/.* rachelpi/'"$RPI"' rachelpi/'  /etc/hosts 

# Restart DNS
/etc/init.d/dnsmasq restart


