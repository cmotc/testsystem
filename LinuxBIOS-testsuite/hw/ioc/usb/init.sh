#!/bin/bash
#
# start ioc handler
#
# init.sh [<device>]
#
#   device: ttyUSB device of ioc or auto.
#

LOC=`dirname $0`

DEVICE=`$LOC/detect.sh $1`
if [ $? == 1 ]; then 
  echo "ioc not connected. bailing out."
  exit 1
fi

echo "initializing ioc."

$LOC/ioc-handler `pwd`/cons-${DEVICE/\/dev\/}.pid $1 &> /dev/null &
sleep 1

$LOC/setio $DEVICE 0 off
$LOC/setio $DEVICE 1 off

PID=`cat cons-${DEVICE/\/dev\/}.pid`
echo "started ioc handler with pid $PID"

