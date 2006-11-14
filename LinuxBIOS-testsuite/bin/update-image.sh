#!/bin/bash
#
# update_image.sh <config> <image> <top>
#

if [ $# -ne 3 -a $# -ne 2 ]; then
  printf "Usage: $0 [config] [image] [topdir]\n"
  exit 1
fi

CONFIG=$1
IMAGE=$2
TOP=$3

if [ "$TOP" == "" ]; then
  $TOP=`pwd`
fi

echo "Config: $CONFIG"
echo "Image:  $IMAGE"
echo "Top:    $TOP"
echo

# read config
source $CONFIG

# initialize hardware 
printf "Initializing ...       "
$TOP/hw/power/$POWER_TYPE/power.sh off $POWER_PORT $POWER_IPADDR
$TOP/hw/ioc/$IOC_TYPE/init.sh &>/dev/null
sleep 1
rm -f $IMAGE.flash.log
printf "ok\n"


# boot the backup firmware
printf "Powering up ...        "
$TOP/hw/ioc/$IOC_TYPE/bios-orig.sh
sleep 1
$TOP/hw/power/$POWER_TYPE/power.sh on $POWER_PORT $POWER_IPADDR
sleep 2
$TOP/hw/ioc/$IOC_TYPE/atx-on.sh
printf "ok\n"

# wait for boot
# expect "*" flushes output.
printf "Waiting for system ... "
( 
cat << EOF 
set timeout 300
log_user 0
spawn $TOP/hw/console/serial/console.sh auto 115200 $TOP/$IMAGE.flash.log
expect { 
  "login:" { send_user "ok\n" }
  timeout  { send_user "timeout\n"; abort }
}
expect "*"
close
EOF
) | expect

chmod 644 $TOP/$IMAGE.flash.log
printf "Network test ...       "
ping -q -c 1 -W 2 $TEST_IPADDR &> /dev/null
if [ $? -eq 0 ]; then
  printf "ok\n"
else
  printf "FLASH FAILED. host is not up. powering off again.\n"
  $TOP/hw/power/$POWER_TYPE/power.sh off $POWER_PORT $POWER_IPADDR
  $TOP/hw/ioc/usb/exit.sh &>/dev/null
  exit 1
fi

#
# Installing flash utility and co on remote host
#
printf "Updating utility ...   "
NEWUTIL=`mktemp /tmp/LinuxBIOS-flashutil.XXXXXXXX`
cp $TOP/bin/flash.sh $NEWUTIL
perl -pi -e "s/SST39SF020A/$BACKUP_CHIP/g" $NEWUTIL
chmod 755 $NEWUTIL
scp $NEWUTIL root@$TEST_IPADDR:/home/core/flash.sh >/dev/null
if [ $? -eq 0 ]; then
  scp $TOP/bin/flashrom root@$TEST_IPADDR:/home/core/flashrom >/dev/null
  if [ $? -eq 0 ]; then
    printf "ok\n"
  else
    printf "FAILED (flashrom)\n"
  fi
else
  printf "FAILED (flash.sh)\n"
fi


## FLASH update
printf "Updating flash ...     "
$TOP/hw/ioc/$IOC_TYPE/bios-new.sh

# if we have a 512k bios savior we need to cat the images together.
if [ $TEST_SIZE == 512 -a `filesize $TOP/$IMAGE` == $(( 256*1024 )) ]; then
  cat $TOP/$IMAGE $TOP/$IMAGE > $TOP/$IMAGE.new
  mv $TOP/$IMAGE.new $TOP/$IMAGE
fi

scp $TOP/$IMAGE root@$TEST_IPADDR:/home/core/images >/dev/null
ssh root@$TEST_IPADDR /home/core/flash.sh /home/core/images/`basename $IMAGE` >/dev/null
if [ $? -eq 0 ]; then
  printf "ok\n"
else
  printf "FAILED\n"
fi

## shutdown
printf "Powering down ...      "
ssh root@$TEST_IPADDR /sbin/halt
( 
cat << EOF 
set timeout 240
log_user 0
spawn -noecho $TOP/hw/console/serial/console.sh auto 115200 $TOP/$IMAGE.flash.log
expect { 
  "Power down." { send_user "ok\n" }
  timeout       { send_user "timeout\n" }
}
expect "*"
close
EOF
) | expect
chmod 644 $TOP/$IMAGE.flash.log

# cleanup
printf "Cleaning up ...        "
$TOP/hw/power/$POWER_TYPE/power.sh off $POWER_PORT $POWER_IPADDR
$TOP/hw/ioc/usb/exit.sh &>/dev/null
printf "ok\n"

printf "`basename $0` ran ${SECONDS}s\n"
