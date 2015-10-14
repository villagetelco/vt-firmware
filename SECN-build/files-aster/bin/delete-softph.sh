#! /bin/sh

# /bin/delete-softph.sh
# Usage:  /bin/delete-softph <softph-number(300-399)>

NUM=$1

PWNUM=";PW"$1
DIRNUM=";DIR"$1
SOFTNUM="softph"$NUM

FILE="/etc/asterisk/softphone.sip.conf"

CHECK=`cat $FILE | grep softph$NUM` # Check to see if entry exists.

if [ $CHECK ]; then  # Delete existing entry
	grep -v $PWNUM $FILE | grep -v $DIRNUM | grep -v $SOFTNUM > /tmp/softphdel.txt
	cp /tmp/softphdel.txt $FILE
	rm /tmp/softphdel.txt
fi



