#!/bin/bash
#
# USAGE: atx-off.sh [<device>]
#

LOC=`dirname $0`

$LOC/setio `$LOC/detect.sh $1` 1 on
sleep 5 # 4s is atx power off time but we dont want a race
$LOC/setio `$LOC/detect.sh $1` 1 off

