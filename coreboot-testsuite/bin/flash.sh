#!/bin/bash

FLASHPART=`~core/flashrom |grep Flash\ part|cut -f4 -d\ `
IMAGE=$1
if [ "$IMAGE" == "" ]; then
  IMAGE=~core/linuxbios.rom
fi

#
# This serves as an example of querying the currently
# used flash part. SST39SF020A is an example used in one
# of our test systems. This gets replaced by the chip set
# in the mainboard config file 
#
if [ "$FLASHPART" == SST39SF020A ]; then
  echo "Wrong position of BIOS savior."
  exit
fi

#
# This should only be executed if the flash device is 512k
#
if [ `filesize $IMAGE` == "$(( 256*1024 ))" ]; then
  cat $IMAGE $IMAGE > $IMAGE.burn
else
  cp $IMAGE $IMAGE.burn
fi

~core/flashrom -w $IMAGE.burn
~core/flashrom -v $IMAGE.burn

