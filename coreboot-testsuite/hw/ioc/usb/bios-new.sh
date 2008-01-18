#!/bin/bash
#
# USAGE: bios-new.sh [<device>]
#
# switch to test bios.
#

LOC=`dirname $0`
$LOC/setio `$LOC/detect.sh $1` 0 on

