#! /bin/sh

# This script sets the wifi "coverage" in the range 0-255
# Each increment corresponds to 3uSec of air propogation time.

COVERAGE=`uci get wireless.radio0.coverage`
PHY=`uci get wireless.radio0.phy`
iw phy $PHY set coverage $COVERAGE

COVERAGE=`uci get wireless.radio1.coverage`
PHY=`uci get wireless.radio1.phy`
iw phy $PHY set coverage $COVERAGE
