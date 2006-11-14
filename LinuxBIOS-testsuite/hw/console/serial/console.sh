#!/bin/bash
#
# USAGE: console.sh [ [ [<dev>|auto] [baud] ] [logfile] ]
#

LOC=`dirname $0`
DEV=$1
SPEED=$2
LOGFILE=$3

DRIVER=ftdi_sio

if [ "$DEV" == "" -o "$DEV" == "auto" ]; then
  DEV=`find /sys/bus/usb-serial/drivers/$DRIVER -name "ttyUSB*"|head -1`
  DEV="/dev/${DEV/*\/}"
fi
if [ "$DEV" == "" ]; then
  echo "Error: could not detect the console device.\n"
  exit 1
fi
# "

if [ "$SPEED" == "" ]; then
  SPEED=115200
fi

if [ "`id -u`" != 0 ]; then
  echo "You might need to be root to execute this command:"
  echo " $ $LOC/serial2stdio $DEV 0 $SPEED $LOGFILE"
  echo
#  exit
fi

echo "Starting console on $DEV with speed $SPEED at `date`."
if [ "$LOGFILE" != "" ]; then
  echo "Writing to logfile $LOGFILE"
fi

# We dont want unreadable logs.
umask 0022

$LOC/serial2stdio $DEV 0 $SPEED $LOGFILE

