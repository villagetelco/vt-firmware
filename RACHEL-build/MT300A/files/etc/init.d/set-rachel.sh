#! /bin/sh

# Wait for memory devices to be available
sleep 10

# ------------------------------

# Make dirs in case it is first boot
mkdir /mnt/sda1
mkdir /mnt/sda2
mkdir /mnt/mmcblk0p1

# Mount the RACHEL memory device in case auto mount did not work.
mount -rw /dev/sda1       /mnt/sda1
mount -rw /dev/sda2       /mnt/sda2
mount -rw /dev/mmcblk0p1  /mnt/mmcblk0p1

# Remove old links
rm /www/rachel/modules
rm /www/rachel/local
rm /www/rachel/modules2
rm /www/rachel/local2
rm /www/rachel/logs

# Set up default home page
ln -s -f /www/rachel/rachel.index.html   /www/rachel/index.html

# Find modules etc directories and force link

# Check for VT-RACHEL MMC/SD card
if [ -e "/mnt/mmcblk0p1/modules" ]; then                            
	ln -s -f /mnt/mmcblk0p1/modules /www/rachel/modules                                     
	ln -s -f /mnt/mmcblk0p1/art     /www/rachel/art                                           
	ln -s -f /mnt/mmcblk0p1/css     /www/rachel/css   
	ln -s -f /mnt/mmcblk0p1/local   /www/rachel/local
	ln -s -f /mnt/mmcblk0p1/index.html /www/rachel/index.html # Set up VT-RACHEL home page
	mkdir /mnt/mmcblk0p1/logs                                                               
	ln -s -f /mnt/mmcblk0p1/logs    /www/rachel/logs                                        
fi                                                    

# Check for VT-RACHEL USB and no MMC/SD
if [ !-e "/mnt/mmcblk0p1/modules" && -e "/mnt/sda1/modules" ]; then
	ln -s -f /mnt/sda1/modules   /www/rachel/modules
	ln -s -f /mnt/sda1/art       /www/rachel/art
	ln -s -f /mnt/sda1/css       /www/rachel/css
	ln -s -f /mnt/sda1/local     /www/rachel/local
	ln -s -f /mnt/sda1/index.html /www/rachel/index.html # Set up VT-RACHEL home page
	mkdir /mnt/sda1/logs
	ln -s -f /mnt/sda1/logs      /www/rachel/logs
fi

# Check for both VT-RACHEL USB and MMC/SD present
if [ -e "/mnt/sda1/modules" && -e "/mnt/mmcblk0p1/modules" ]; then
	mkdir /www/rachel/modules2
	mkdir /www/rachel/local2
	ln -s -f /mnt/sda1/modules      /www/rachel/modules2
	ln -s -f /mnt/sda1/local        /www/rachel/local2
	# Use index.html on USB for the home page. 
	# It may point to index1.html from the MMC/SD card to allow access to that content.
	ln -s -f /mnt/sda1/index.html   /www/rachel/index.html
	ln -s -f /mnt/mmcblk0p1/index.html /www/rachel/index1.html
fi

# Make sure cache directory exists
if [ ! -d /mnt/sda1/cache ]; then 
	mkdir /mnt/sda1/cache    
fi 
if [ ! -d /mnt/mmcblk0p1/cache ]; then 
	mkdir /mnt/mmcblk0p1/cache    
fi 
# Set up cache directory on MMC/SD or USB
if [ -e /dev/sda1 ]; then 
	uci set polipo.cache.diskCacheRoot="/mnt/sda1/cache"
	uci commit polipo
elif [ -e /dev/mmcblk0p1 ]; then 
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

