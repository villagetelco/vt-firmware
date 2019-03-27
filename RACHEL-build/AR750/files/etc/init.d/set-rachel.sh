#! /bin/sh

# Wait for memory devices to be available
sleep 10

# ------------------------------

# Mount the memory device in case auto mount did not work.
# /dev/sda is SD card and /dev/sdb is USB 

# Make dirs in case it is first boot
mkdir /mnt/sda1
mkdir /mnt/sda2
mkdir /mnt/sdb1
mkdir /mnt/sdb2

if [ -e "/dev/sda1" ]; then
mount -rw /dev/sda1  /mnt/sda1
fi
if [ -e "/dev/sda2" ]; then
mount -rw /dev/sda2  /mnt/sda2
fi
if [ -e "/dev/sdb1" ]; then
mount -rw /dev/sdb1  /mnt/sdb1
fi
if [ -e "/dev/sdb2" ]; then
mount -rw /dev/sdb2  /mnt/sdb2
fi

# Remove old links
rm /www/rachel
rm /www/rachel-local2

#Set up default Rachel directory in case there are no memory devices installed
ln -s -f /www/rachel-x /www/rachel

# Find library memory device and link to it
# Check for SD library on "sda1"
if [ -e "/mnt/sda1/##LIBRARY##" ]; then
	rm /www/rachel
	ln -s -f /mnt/sda1	/www/rachel

	if [ ! -d /mnt/sda1/cache ]; then # Make sure cache directory exists
		mkdir /mnt/sda1/cache    
	fi 

	if [ ! -d /mnt/sda1/logs ]; then # Make sure logs directory exists
		mkdir /mnt/sda1/logs    
	fi

	if [ -e "/dev/sdb1" ]; then # Check for USB device to use for additional local content
		ln -s -f /mnt/sdb1 /www/rachel-local2
	fi
fi

# Check for USB library on "sdb1". This will be used if present in lieu of SD.
if [ -e "/mnt/sdb1/##LIBRARY##" ]; then
	rm /www/rachel
	ln -s -f /mnt/sdb1 	/www/rachel

	if [ ! -d /mnt/sdb1/cache ]; then # Make sure cache directory exists
		mkdir /mnt/sdb1/cache    
	fi 

	if [ ! -d /mnt/sdb1/logs ]; then # Make sure logs directory exists
		mkdir /mnt/sdb1/logs    
	fi 

	if [ -e "/dev/sda1" ]; then # Check for SD device to use for additional local content
		ln -s -f /mnt/sda1 /www/rachel-local2
	fi
fi

# Set up logs
mv /www/rachel/logs/log4.txt  /www/rachel/logs/log5.txt
mv /www/rachel/logs/log3.txt  /www/rachel/logs/log4.txt
mv /www/rachel/logs/log2.txt  /www/rachel/logs/log3.txt
mv /www/rachel/logs/log1.txt  /www/rachel/logs/log2.txt
mv /www/rachel/logs/log.txt   /www/rachel/logs/log1.txt

echo "Start session" > /www/rachel/logs/log.txt

# -----------------------------

