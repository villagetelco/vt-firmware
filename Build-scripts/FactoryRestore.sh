#! /bin/sh

# This script builds the Factory Restore tar file from files in /etc/config

cd ./files/etc/config/

rm conf-default.tar.gz

tar -czvf conf-default.tar.gz ./*

cd ../../..


