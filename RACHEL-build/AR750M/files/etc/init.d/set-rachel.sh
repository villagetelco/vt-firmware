#! /bin/sh

# Wait for memory devices to be available
sleep 10

# ------------------------------

# Mount the RACHEL memory device in case auto mount did not work.
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
rm /www/rachel/modules
rm /www/rachel/local
rm /www/rachel/logs

# Set up default home page
ln -s -f /www/rachel/rachel.index.html   /www/rachel/index.html

# Find modules etc directories and force link
# Check for VT-RACHEL SD
if [ -e "/mnt/sda1/modules" ]; then
	ln -s -f /mnt/sda1/modules		/www/rachel/modules
	ln -s -f /mnt/sda1/art   			/www/rachel/art
	ln -s -f /mnt/sda1/css   			/www/rachel/css
	ln -s -f /mnt/sda1/local			/www/rachel/local
	ln -s -f /mnt/sda1/index.html	/www/rachel/index.html # Set up VT-RACHEL home page
	if [ ! -d /mnt/sda1/cache ]; then # Make sure cache directory exists
		mkdir /mnt/sda1/cache    
	fi 
	if [ ! -d /mnt/sda1/logs ]; then # Make sure logs directory exists
		mkdir /mnt/sda1/logs    
	fi 
fi

# Check for second VT-RACHEL USB. This will be used if present in lieu of USB.
if [ -e "/mnt/sdb1/modules" ]; then
	ln -s -f /mnt/sdb1/modules 		/www/rachel/modules
	ln -s -f /mnt/sda1/art				/www/rachel/art
	ln -s -f /mnt/sda1/css   			/www/rachel/css
	ln -s -f /mnt/sdb1/local   		/www/rachel/local
	ln -s -f /mnt/sdb1/index.html	/www/rachel/index.html # Set up VT-RACHEL home page
	if [ ! -d /mnt/sdb1/cache ]; then # Make sure cache directory exists
		mkdir /mnt/sdb1/cache    
	fi 
	if [ ! -d /mnt/sdb1/logs ]; then # Make sure logs directory exists
		mkdir /mnt/sdb1/logs    
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

