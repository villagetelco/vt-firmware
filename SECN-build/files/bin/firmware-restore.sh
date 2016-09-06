#!/bin/sh

# /bin/firmware-restore.sh
# This script is called when button is pressed an released after 20 - 30 seconds
# Author TLG

# Restore firmware
rm -r /overlay/*  &&  reboot

