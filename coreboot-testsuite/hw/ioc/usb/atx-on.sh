#!/bin/bash
#
# USAGE: atx-on.sh [<device>]
#

LOC=`dirname $0`

$LOC/setio `$LOC/detect.sh $1` 1 on
$LOC/setio `$LOC/detect.sh $1` 1 off

