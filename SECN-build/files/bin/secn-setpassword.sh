#!/bin/sh
# /bin/secn-setpassword
# Usage secn-setpassword <password1> <password2> [<username>] Default is root.
# Note: Passwords are already validated to be the same in SECN screen.

PASS1=`echo "$1" | sed -f /bin/url-decode.sed`
PASS2=`echo "$2" | sed -f /bin/url-decode.sed`

date > /tmp/setpassword.txt

(echo $PASS1; sleep 1; echo $PASS2) | passwd $3 >> /tmp/setpassword.txt

cat /tmp/setpassword.txt | grep change > /tmp/passwordstatus.txt
echo ". Reboot to activate web UI Authentication" >> /tmp/passwordstatus.txt
uci set secn.http.pw_preset="1"
uci set secn.http.auth="checked"
uci commit secn

