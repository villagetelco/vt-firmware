#!/bin/sh

# /bin/ restartasterisk.sh 
# Restart Asterisk from IVR command 9999
# Author TLG

# Get PIN and Confirmation code from temp file and delete
PINNUM=`cat /tmp/restart.txt | awk '{ print $1 }'`
RESTART=`cat /tmp/restart.txt | awk '{ print $2 }'`
rm /tmp/restart.txt

# Check the Pin and Confirm Code, and if not OK, set result message to FAIL and exit
PIN=`uci get secn.ivr.pin`
if [ $PIN != $PINNUM ] || [ $RESTART != "1" ] ; then
echo "Fail and exit - PIN:"  $PINNUM   RESTART  $RESTART   >  /tmp/test.txt
  cp /usr/lib/asterisk/sounds/fail.gsm /tmp/result.gsm
  exit
  fi

# Setup success result message
cp /usr/lib/asterisk/sounds/success.gsm /tmp/result.gsm

# Restart Asterisk
/etc/init.d/asterisk stop > /dev/null &
sleep 20  # Allow time to stop completely
/etc/init.d/asterisk start > /dev/null &
# Allow time to register
sleep 5
exit

