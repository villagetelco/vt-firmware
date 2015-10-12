#! /bin/sh

#  /bin/usbmodem.sh - Get details of USB devices for display

MANF=`cat /sys/kernel/debug/usb/devices  | grep -A 1 "P:  Vendor" | grep -A 2  "\-\-" | grep S: | cut -d = -f 2`                        
CODES=`cat /sys/kernel/debug/usb/devices | grep -A 1 "P:  Vendor" | grep -A 2  "\-\-" | grep P: | cut -d = -f 1,2,3 | cut -d " " -f 2,3,4`

echo $MANF"  "$CODES # > /tmp/usbmodem.txt


