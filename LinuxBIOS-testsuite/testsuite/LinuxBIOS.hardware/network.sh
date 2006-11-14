#!/bin/bash

TEST_IPADDR=$1
printf "[network] Testing network access to test host $TEST_IPADDR... "
ping -q -c 1 -W 2 $TEST_IPADDR &> /dev/null
if [ $? -eq 0 ]; then
  printf "NETWORK OK.\n"
else
  printf "NETWORK FAILED.\n"
fi


