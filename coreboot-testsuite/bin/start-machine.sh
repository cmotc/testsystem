#!/bin/bash
#
# start-machine.sh <config>
#

CONFIG=$1
TOP=`pwd`

if [ "$CONFIG" == "" -o ! -r "$CONFIG" ]; then
  printf "Usage: $0 <configfile>\n"
  exit 1
fi

# read config
source $CONFIG

# initialize hardware 
printf "Initializing..."
$TOP/hw/power/$POWER_TYPE/power.sh off $POWER_PORT $POWER_IPADDR
$TOP/hw/ioc/$IOC_TYPE/init.sh &>/dev/null
sleep 1
printf "ok\n"


# boot the backup firmware
printf "Powering up ..."
$TOP/hw/ioc/$IOC_TYPE/bios-orig.sh
$TOP/hw/power/$POWER_TYPE/power.sh on $POWER_PORT $POWER_IPADDR
sleep 2
$TOP/hw/ioc/$IOC_TYPE/atx-on.sh
printf "ok\n"

## wait for boot
printf "Waiting for system ..."
( 
cat << EOF 
set timeout -1
spawn $TOP/hw/console/serial/console.sh
expect "login:"
EOF
) | expect &> /dev/null
printf "ok\n"

$TOP/hw/console/serial/console.sh

