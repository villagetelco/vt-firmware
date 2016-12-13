#! /bin/sh

# This script sets the wifi "coverage" 0-99
# Each increment corresponds to 3uSec of air propogation time.

COVERAGE=`uci get wireless.radio0.coverage`
iw phy phy0 set coverage $COVERAGE
