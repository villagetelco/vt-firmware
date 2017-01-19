#! /bin/sh

# Wait for memory devices to be available
sleep 5
# ------------------------------

# Make dirs in case it is first boot
mkdir /mnt/sda1
mkdir /mnt/sda2
mkdir /mnt/mmcblk0p1

# Un-mount the RACHEL memory devices.
umount  /mnt/sda1
umount  /mnt/mmcblk0p1

# Remove old links
rm /www/rachel

SDA=0
# Mount the RACHEL memory devices and check for 'modules' dir.                                     
if mount -rw /dev/sda1 /mnt/sda1; then
  if [ -e /mnt/sda1/modules ]; then
    echo "sda1 modules available"
    SDA=1
  fi
fi  

MMC=0                                                                 
if mount -rw /dev/mmcblk0p1 /mnt/mmcblk0p1; then
  if [ -e /mnt/mmcblk0p1/modules ]; then
    echo "mmc modules available"
    MMC=1
  fi
fi

# Find contents directories and force link to /www/rachel

# Check for VT-RACHEL MMC/SD card alone
if [ $MMC == 1 ] && [ $SDA != 1 ]; then
  echo "Got MMC RACHEL mem only"
		ln -s -f /mnt/mmcblk0p1 /www/rachel                                     
		mkdir /www/rachel/logs                                                               

# Check for VT-RACHEL USB alone
elif [ $MMC != 1 ] && [ $SDA == 1 ]; then 
	  echo "Got USB RACHEL mem only"
		ln -s -f /mnt/sda1   /www/rachel
		mkdir /www/rachel/logs

# Check for both VT-RACHEL USB and MMC/SD present
elif [ $MMC == 1 ] && [ $SDA == 1 ]; then
	echo "Got both MMC and USB RACHEL memories"
	ln -s -f /mnt/sda1   /www/rachel
	mkdir /www/rachel/logs
else
	echo "There is no RACHEL memory device present"
	ln -s -f /www/rachel-x   /www/rachel
	ln -s -f /www/rachel/rachel.index.html   /www/rachel/index.html
fi

# Set up cache directory on MMC/SD or USB
if [ -e /dev/sda1 ]; then
	mkdir /mnt/sda1/cache 
	uci set polipo.cache.diskCacheRoot="/mnt/sda1/cache"
	uci commit polipo
elif [ -e /dev/mmcblk0p1 ]; then 
	mkdir /mnt/mmcblk0p1/cache
	uci set polipo.cache.diskCacheRoot="/mnt/mmcblk0p1/cache"
	uci commit polipo
else
	uci set polipo.cache.diskCacheRoot=""
	uci commit polipo
fi 

# Set up logs
mv /www/rachel/logs/log4.txt  /www/rachel/logs/log5.txt
mv /www/rachel/logs/log3.txt  /www/rachel/logs/log4.txt
mv /www/rachel/logs/log2.txt  /www/rachel/logs/log3.txt
mv /www/rachel/logs/log1.txt  /www/rachel/logs/log2.txt
mv /www/rachel/logs/log.txt   /www/rachel/logs/log1.txt

echo "Start session" > /www/rachel/logs/log.txt

# -----------------------------

