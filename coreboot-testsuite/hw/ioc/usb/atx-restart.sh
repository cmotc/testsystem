#!/bin/bash
#
# USAGE: atx-restart.sh [<device>]
#

LOC=`dirname $0`

$LOC/atx-off.sh $1
sleep 1
$LOC/atx-on.sh $1

