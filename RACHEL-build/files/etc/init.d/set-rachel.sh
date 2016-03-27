#! /bin/sh

# Wait for memory devices to be available
sleep 2

# ------------------------------

# Mount the RACHEL memory device in case auto mount did not work.
# Make dirs in case it is first boot
mkdir /mnt/sda1
mkdir /mnt/sda2

mount -rw /dev/sda1  /mnt/sda1
mount -rw /dev/sda2  /mnt/sda2

# Remove old links
rm /www/rachel/modules
rm /www/rachel/local
rm /www/rachel/logs

# Set up default home page
ln -s -f /www/rachel/rachel.index.html   /www/rachel/index.html

# Find modules directory and force link

# Check for VT-RACHEL SD/USB
if [ -e "/mnt/sda1/modules" ]; then
	ln -s -f /mnt/sda1/modules /www/rachel/modules
	ln -s -f /mnt/sda1/local   /www/rachel/local
	ln -s -f /mnt/sda1/index.html   /www/rachel/index.html # Set up VT-RACHEL home page
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

