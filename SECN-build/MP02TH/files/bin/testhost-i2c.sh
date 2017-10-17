#! /bin/sh

# /bin/logscript.sh
# This script runs on the test host device.
# It calls a test script on the DUT every minute, collects the results, 
# adds local data and updates the test logfile entry in /tmp/testlog.txt
# Note that the test logfile is not persistent!!
# The logfile is linked to /www/testlog.txt so it can be accessed by browser
# at http:<test_host_ip>/testlog.txt

USAGE="Usage:   ./logscript.sh   <IP_address_of_DUT>  <Minutes_to_Run"

if [ $# != "2" ] || [ $1 == "--help" ]; then
	echo " "
	echo $USAGE
	echo " "
	exit
fi

# Setup DUT IP address and time to run
DUT=$1
MAXMINS=$2

if !(ping -c 1 $DUT &> /dev/null)
then
	echo ""
	echo "Unable to ping DUT IP address"
	echo ""
	echo $USAGE
	echo " "
	exit
fi


# Set up www link to testlog file
touch /tmp/testlog.txt
if [ ! -e /www/testlog.txt ]; then
	ln -s /tmp/testlog.txt /www/testlog.txt
fi

# Initialise the testlog file
DATE=$(date)
echo "Log start: $DATE "                  >  /tmp/testlog.txt
echo "DUT: $DUT  Duration: $MAXMINS mins" >> /tmp/testlog.txt
echo ""                                   >> /tmp/testlog.txt

echo ""
echo "Log start: $DATE "
echo "DUT: $DUT  Duration: $MAXMINS mins"
echo ""

# Start test run
SEC=$(date +"%S")
mins=0

while [ $mins -le $MAXMINS ]
do
	SEC=$(date +"%S")
	# Run on the minute
	if [ $SEC == "00" ]; then
		# Increment the minutes counter
		mins=$(( mins+1 ))	

		# Run tests on DUT and get results string
		TESTSTR=$(wget -q -O - http://$DUT/cgi-bin/test.html) 

		# Get local test data
		#TEMP=$(/bin/gettemp-w1.sh)
		TEMP=$(/bin/gettemp-i2c.sh)
		DATE=$(date +"20%y-%m-%d %H:%M:%S")
		RSSI=$(iw dev wlan0-1 station dump | grep "signal avg:"|cut  -f 3|cut -d " " -f1,3)

		# Save to test log file
		echo "$DATE Temp: "$TEMP" C RSSI: $RSSI $TESTSTR"		>> /tmp/testlog.txt
		echo "$DATE Temp: "$TEMP" C RSSI: $RSSI $TESTSTR"
		sleep 50
	fi
	sleep 1
done

echo "Test run completed" >> /tmp/testlog.txt

echo ""
echo "Test run completed"
echo ""

exit

