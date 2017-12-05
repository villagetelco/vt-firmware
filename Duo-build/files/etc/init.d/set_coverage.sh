#! /bin/sh

# This script sets the wifi "coverage" 0-99
# Each increment corresponds to 3uSec of air propogation time.

# Check assignment of phy0, phy1
WIFI_INT=`uci get wireless.radio0.phy`

if [ $WIFI_INT = "phy0" ]; then	
	COVERAGE=`uci get wireless.radio0.coverage`
	iw phy phy0 set coverage $COVERAGE  >  /dev/null
	COVERAGE=`uci get wireless.radio1.coverage`
	iw phy phy1 set coverage $COVERAGE  >  /dev/null
else
	COVERAGE=`uci get wireless.radio0.coverage`
	iw phy phy1 set coverage $COVERAGE  >  /dev/null
	COVERAGE=`uci get wireless.radio1.coverage`
	iw phy phy0 set coverage $COVERAGE  >  /dev/null
fi
