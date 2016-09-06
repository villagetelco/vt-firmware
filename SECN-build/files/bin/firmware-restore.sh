#!/bin/sh

# /bin/firmware-restore.sh
# This script is called when button is pressed an released after 20 - 30 seconds
# Author TLG

# Restore configuration to factory defaults
cd /etc
tar -xzf conf-default.tar.gz >> /dev/null
cd

# Restore firmware
rm -r /overlay/*  &&  reboot

