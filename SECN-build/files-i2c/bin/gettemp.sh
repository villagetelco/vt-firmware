#! /bin/sh

# gettemp.sh
# Reads temperature register from DS3231 module

I2CBUS="0"
RTCADDR="0x68"
TEMPREG1="0x11"
TEMPREG2="0x12"

# Get temp data from RTC
T1=$(i2cget -y $I2CBUS $RTCADDR $TEMPREG1)
# Convert to decimal
t1=$(($T1))  

# Get fractional temp data from RTC and convert
T2=$(i2cget -y $I2CBUS $RTCADDR $TEMPREG2)
case $T2 in
	0x00) t2=".0 ";;
	0x40) t2=".25";;
	0x80) t2=".5 ";;
	0xc0) t2=".75";;
esac
# Output the temp
echo "$t1$t2"
