# vendor:board:suffix:payload-dir
# via:epia-m:filo:filo/cf-epia-m

if [ $# -lt 2 ]; then
  echo "Usage: $0 vendor board <payload type>"
  exit 1
fi

cd `dirname $0`

VENDOR=$1
BOARD=$2
PTYPE=$3

if [ "$PTYPE" == "" ]; then
  PTYPE=filo
fi

FINAL=`
cat boards.cfg | while read entry; do 
  vendor=\`echo $entry|cut -f1 -d\:\`
  board=\`echo $entry|cut -f2 -d\:\`
  ptype=\`echo $entry|cut -f3 -d\:\`
  pload=\`echo $entry|cut -f4 -d\:\`

  if [ "$vendor" != "$VENDOR" ]; then
    continue;
  fi
  if [ "$board" != "$BOARD" ]; then
    continue;
  fi
  if [ "$ptype" != "$PTYPE" ]; then
    continue;
  fi
  
  # Debug
  # printf "Found..\n   board: $vendor $board\n   type: $ptype\n   path: $pload\n"
  printf "\`pwd\`/payloads/$pload\n"
  
done
`
if [ "$FINAL" != "" ]; then
  printf "$FINAL\n"
else
  # as long as we don't have a default payload:
  #printf "/dev/null\n"
  printf "`pwd`/payloads/default/filo-0.5.0.elf\n"
fi

