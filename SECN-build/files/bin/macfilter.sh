#! /bin/sh

# /bin/macfilter.sh
# Usage:  /bin/macfilter.sh  allow|deny|disable  [[-f filename] | [-m "mac_string"]]
# Reads MAC address list (space separated) from command line as a quoted string, or
# Reads a file containing MAC addresses, space separated on one or more lines.

if [ $1 = "allow" ] || [ $1 = "deny" ] || [ $1 = "disable" ]; then
  uci set wireless.ap_0.macfilter=$1
else
  exit
fi

if [ $2 = "-f" ]; then
  MACLIST=`tr '\n' ' ' < $3` # Convert file to string, replacing newlines with space
  uci set wireless.ap_0.maclist="$MACLIST"
elif [ $2 = "-m" ]; then
  MACLIST=$3
  uci set wireless.ap_0.maclist="$MACLIST"
fi

uci commit wireless


