#!/bin/sh

WORKDIR=`pwd`
LOCATION=`dirname $0`
PLUGIN=$1

if [ "$1" == "" ]; then 
  echo "Usage: $0 <plugin-name>"
  exit 1
fi

cd $LOCATION
cat REVISION
LD_LIBRARY_PATH=. DEBUG=1 plugins/$1

cd $WORKDIR

