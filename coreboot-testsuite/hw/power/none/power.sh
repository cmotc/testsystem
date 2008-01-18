#!/bin/bash

# USAGE:
#
#  power.sh [on|off] [1|2|3|4]
#

LOC=`dirname $0`

if [ "$1" != "on" -a "$1" != "off" ]; then
   printf "$0: error: state can only be on or off.\n"
   printf "\nUsage: $0 [on|off] [1|2|3|4]\n\n"
   exit
fi

POS=$1
PORT=$2

printf "power switch hw not available. Ignore switching port $PORT to $POS\n"

