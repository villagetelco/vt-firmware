#! /bin/sh

# This script builds the Factory Restore tar file from files and directories in /etc

cd ./files/etc/

rm conf-default.tar.gz

tar -czvf conf-default.tar.gz config profile 

cd ../..


