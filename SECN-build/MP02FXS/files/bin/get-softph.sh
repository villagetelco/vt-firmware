#! /bin/sh

# /bin/get-softph.sh

FILE="/etc/asterisk/softphone.sip.conf"

cat $FILE |grep -A 1 "(softph)" | cut -d "(" -f 1 |cut -d ";" -f 1 | \
sed s/secret=/"Password: "/ | sed s/dirname=/"Name:  "/ | \
sed s/softph/"Number: "/  > /tmp/softph.txt

