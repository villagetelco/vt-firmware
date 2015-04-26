#! /bin/sh

# /bin/set-softph.sh
# Usage:  /bin/set-softph <softph-number(300-399)> P:<softph-pwd> D:<softph-dirname>

NUM=$1
PW=`echo $2 | cut -d : -f 2`
DIR=`echo $3 | cut -d : -f 2`

# Check for missing number arg
TEST=`echo $1 | cut -d ":" -f1`
if [ $TEST = "P" ] || [ $TEST = "D" ]; then
  echo "Exiting"  >> /tmp/debug.txt
  exit
fi

PWNUM=PW$1
DIRNUM=DIR$1

FILE="/etc/asterisk/softphone.sip.conf"

CHECK=`cat $FILE | grep softph$NUM` # Check to see if entry exists.

if [ $CHECK ]; then  # Update existing entry
  if [ $PW ]; then
    sed -i 's/secret=.*;'"$PWNUM"'.*/secret='"$PW"' ;'"$PWNUM"' /'  $FILE
  fi
  if [ $DIR ]; then
    sed -i 's/dirname=.*;'"$DIRNUM"'.*/dirname='"$DIR"' ;'"$DIRNUM"' /'  $FILE
  fi
else  # Create new entry
  echo " "                       >> $FILE
  echo "[softph"$1"](softph)"    >> $FILE
  echo "  dirname=$DIR ;DIR"$NUM >> $FILE
  echo "  secret=$PW ;PW"$NUM   >> $FILE
fi


