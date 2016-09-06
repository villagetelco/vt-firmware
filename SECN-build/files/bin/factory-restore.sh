#!/bin/sh

# /bin/factory-restore.sh
# This script is called when button is pressed an released after 10 - 20 seconds
# Author TLG

# Restore configuration to factory defaults
cd /etc
tar -xzf conf-default.tar.gz >> /dev/null
cd

