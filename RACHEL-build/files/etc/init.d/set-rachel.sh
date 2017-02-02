#! /bin/sh

# Wait for memory devices to be available
sleep 15

# Make dirs in case it is first boot
mkdir /mnt/sda1
mkdir /mnt/sdb1
mkdir /mnt/sdc1

# Unmount memory
umount /mnt/sda1
umount /mnt/sdb1
umount /mnt/sdc1

# Remove old links                                              
rm /www/rachel
rm /www/rachel_b
rm /www/rachel_c

# Mount memories and link
if [ -e /dev/sda1 ]; then
	mount -rw /dev/sda1  /mnt/sda1
	ln -s -f /mnt/sda1   /www/rachel
else # No memory present, point to dummy page
	ln -s -f /www/rachel-x /www/rachel
	ln -s -f /www/rachel/rachel.index.html   /www/rachel/index.html
fi

if [ -e /dev/sdb1 ]; then
	mount -rw /dev/sdb1  /mnt/sdb1
	ln -s -f /mnt/sdb1   /www/rachel_b
fi

if [ -e /dev/sdc1 ]; then
	mount -rw /dev/sdc1  /mnt/sdc1
	ln -s -f /mnt/sdc1   /www/rachel_c
fi

# Set up cache
if [ -e /dev/sda1 ]; then
	mkdir /mnt/sda1/cache 
	uci set polipo.cache.diskCacheRoot="/mnt/sda1/cache"
	uci commit polipo
else
	uci set polipo.cache.diskCacheRoot=""
	uci commit polipo
fi

# Set up logs
mv /www/rachel/logs/log2.txt  /www/rachel/logs/log3.txt
mv /www/rachel/logs/log1.txt  /www/rachel/logs/log2.txt
mv /www/rachel/logs/log.txt   /www/rachel/logs/log1.txt

echo "Start session" > /www/rachel/logs/log.txt
date >> /www/rachel/logs/log.txt
# -----------------------------

