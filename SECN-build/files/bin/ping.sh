#!/bin/sh 
ALIVE=`ping -w1 -c1 -q $1 | grep round | sed 's|.*/\([0-9]*\)\.[0-9]*/.*|\1|'`
if [ $ALIVE > 0 ]; then
	echo -n "<div class='gwSuccess'>$ALIVE ms</div>"	
else
	echo -n "<div class='gwError'>n/a</div>"
fi
