#! /bin/sh
 
# /bin/gettemp.sh
# Get temp data string from DS18B20 devices on the first W1 bus
echo $(awk -F= '/t=/ {printf "%.03f\n", $2/1000}' /sys/devices/w1_bus_master1/28-*/w1_slave &)
exit
