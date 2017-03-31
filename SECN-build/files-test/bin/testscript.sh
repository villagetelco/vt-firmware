!# /bin/sh

# /bin/testscript.sh
# This script is located on the DUT and is executed on wget request 
# to /www/cgi-bin/test.html

# Run tests

# Test 1. Ping Internet address
if ping -c 1 8.8.8.8 &> /dev/null
then
	PING1="OK"
else
	PING="FAIL"
fi

# Test 2. Get CPU usage
CPU=$(uptime|cut -d "," -f2|cut -d ":" -f 2)

# Output the test results string
echo "Ping: $PING1  CPU: $CPU "

exit


