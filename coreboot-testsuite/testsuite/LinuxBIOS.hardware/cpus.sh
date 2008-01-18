#!/bin/bash

EXPECTEDCPUS=$1
EXPECTEDCLOCK=$2

if [ "$EXPECTEDCPUS" == "" ]; then EXPECTEDCPUS=0; fi
if [ "$EXPECTEDCLOCK" == "" ]; then EXPECTEDCLOCK=0; fi

NUMCPUS=`grep cpu\ MHz /proc/cpuinfo|wc -l`
CLOCKRATE=`dmesg | grep Detected.*MHz\ processor.|head -1|cut -f2 -d\ `
if [ "$CLOCKRATE" == "" ]; then
  CLOCKRATE=`grep cpu\ MHz /proc/cpuinfo|head -1|cut -f2 -d\:`
fi
LOWCLOCK=`echo $EXPECTEDCLOCK \* 0\.95 | bc -l`
HIGHCLOCK=`echo $EXPECTEDCLOCK \* 1\.05 | bc -l`

printf "Found $NUMCPUS CPUs at $CLOCKRATE MHz. Expected $EXPECTEDCPUS at $EXPECTEDCLOCK MHz."
printf " Accepted clock range: $LOWCLOCK - $HIGHCLOCK MHz\n"

if [ $NUMCPUS != $EXPECTEDCPUS ]; then
  echo "CHECKNOCPUS: FAILED"
else
  echo "CHECKNOCPUS: PASSED"
fi
if [ ${CLOCKRATE%.*} -ge ${LOWCLOCK%.*} -a ${CLOCKRATE%.*} -le ${HIGHCLOCK%.*} ]; then
  echo "CHECKCLOCKRATE: PASSED"
else
  echo "CHECKCLOCKRATE: FAILED"
fi
 
