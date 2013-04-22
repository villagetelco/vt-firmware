#! /bin/sh

# Make script for all TP Link devices
# Ver 3.2

# Check to see if script has not already run and do initial set up
if [ ! -f ./already_configured ]; then 
  # make sure it only executes once
  touch ./already_configured  

  echo " Make builds directory"
  mkdir ./bin/
  mkdir ./bin/ar71xx/
  mkdir ./bin/ar71xx/builds
  mkdir ./bin/atheros/
  mkdir ./bin/atheros/builds

  echo " Initial set up completed "
  echo ""

else
  echo " Already configured"
  echo ""
fi


