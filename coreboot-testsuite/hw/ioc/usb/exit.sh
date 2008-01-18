#!/bin/bash
#
# exit.sh [<device>]
#
# kill ioc-handler for device
#
#

LOC=`dirname $0`
DEVICE=`$LOC/detect.sh $1`
PIDFILE=cons-${DEVICE/\/dev\/}.pid

if [ ! -r $PIDFILE ]; then
  echo "no pid file."
  exit 1
fi

P1=`cat $PIDFILE`

P2=`pstree -p $P1`
P2=${P2/*(/}
P2=${P2/)}

echo "Stopping IOC handler with pid $P1, $P2"
kill $P2
kill $P1

rm $PIDFILE

