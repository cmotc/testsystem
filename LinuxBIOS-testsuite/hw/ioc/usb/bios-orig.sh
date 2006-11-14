#!/bin/bash
#
# USAGE: bios-orig.sh [<device>]
#
# switch to backup bios.
#

LOC=`dirname $0`
$LOC/setio `$LOC/detect.sh $1` 0 off

