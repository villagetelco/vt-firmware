#! /bin/sh

# This script sets the wifi "coverage" in the range 0-255
# Each increment corresponds to 3uSec of air propogation time.

COVERAGE=`uci get wireless.radio0.coverage`
iw phy phy0 set coverage $COVERAGE  > /dev/null

