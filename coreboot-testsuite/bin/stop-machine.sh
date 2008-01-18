#!/bin/bash
#
# stop-machine.sh <config> <image> <top>
#

CONFIG=$1
TOP=`pwd`

if [ "$CONFIG" == "" -o ! -r "$CONFIG" ]; then
  printf "Usage: $0 <configfile>\n"
  exit 1
fi

# read config
source $CONFIG

## shutdown
printf "Powering down ... "
ssh root@$TEST_IPADDR /sbin/halt
( 
cat << EOF 
set timeout -1
spawn -noecho $TOP/hw/console/serial/console.sh
expect "Power down."
EOF
) | expect &> /dev/null
printf "ok\n"

# cleanup
printf "Cleaning up ... "
$TOP/hw/power/$POWER_TYPE/power.sh off $POWER_PORT $POWER_IPADDR
$TOP/hw/ioc/usb/exit.sh &>/dev/null
printf "ok\n"
