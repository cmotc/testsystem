#!/bin/bash
#
# tries to autodetect the io switch. This is very environment specific.
# It takes the first pl2303 controller available because I only used 
# pl2303 devices for building the io switch. -stepan
#

DEV=$1
DRIVER=pl2303
if [ "$DEV" == "" -o "$DEV" == "auto" ]; then
  DEV=`find /sys/bus/usb-serial/drivers/$DRIVER -name "ttyUSB*"|head -1`
  DEV="/dev/${DEV/*\/}"
fi

# bail out if no device was found.
if [ "$DEV" == "/dev/" ]; then
  echo /dev/null
  exit 1
fi

echo "$DEV"

