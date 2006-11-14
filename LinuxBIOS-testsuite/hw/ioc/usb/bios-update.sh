#!/bin/bash
#
# this script does the following:
#  - switch to the testbios
#  - copy an image to the remote machine
#  - flash and verify image on the remote machine
#
# USAGE: bios-update [ [ [<image>] [<remoteip>] ] [<device>] ]
#

LOC=`dirname $0`
IMAGE=~stepan/svn/LinuxBIOSv2/targets/linuxbios.rom
REMOTEIP=192.168.0.201

if [ "$1" != "" ]; then
  IMAGE=$1
fi

if [ "$2" != "" ]; then
  REMOTEIP=$2
fi
REMOTEDIR=root@$REMOTEIP:~core

DEV=$3

$LOC/bios-new.sh $DEV

scp $IMAGE $REMOTEDIR
ssh root@$REMOTEIP ~core/flash.sh

