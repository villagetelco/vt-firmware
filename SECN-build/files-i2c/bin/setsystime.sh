#! /bin/sh

# setsystime.sh
# Sets the system time from the RTC

I2CBUS="0"
RTCADDR="0x68"
TIMEREGS="0-6"

# Get data from RTC
str=$(i2cdump -y -r $TIMEREGS $I2CBUS $RTCADDR b | grep "00:" | cut -d : -f2 | cut -c 2-21)

# Get fields
ss=$(echo $str | cut -d " " -f1)
mm=$(echo $str | cut -d " " -f2)
hh=$(echo $str | cut -d " " -f3)
DD=$(echo $str | cut -d " " -f5)
MM=$(echo $str | cut -d " " -f6)
YY=$(echo $str | cut -d " " -f7)

# Set system time and date
date -s "$YY$MM$DD$hh$mm.$ss" > /dev/null

