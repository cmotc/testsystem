#!/bin/bash
#
# bios-recovery.sh [<device>]
#
# switch to backup bios and restart
#

cd `dirname $0`
./bios-orig.sh $1
./atx-restart.sh $1
