#! /bin/sh

# setrtctime.sh
# Set the time on the RTC from the system time

I2CBUS="0"
RTCADDR="0x68"
TIMEREG="0"
CTRLREG="0xe"
EOSCMASK="0x80"

# Build the date string
DATE=`date +"0x%S 0x%M 0x%H 00 0x%d 0x%m 0x%y"`

# Write to sequential register locations in the RTC
i2cset -y  $I2CBUS $RTCADDR $TIMEREG  $DATE i

# Enable the RTC for battery operation
i2cset -y -m $EOSCMASK $I2CBUS $RTCADDR $CTRLREG 0x00
