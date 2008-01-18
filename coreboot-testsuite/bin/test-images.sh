#!/bin/bash

printf "\n"
TOP=`pwd`
TEMP=$TOP/results

printf "Detecting Boards..."
BOARDS=`find images/ -type d|grep -v .svn|cut -f3 -d/|sort -u|grep -v  ^\\.$ |grep -v ^$`
printf "ok.\n"

rm -rf $TEMP
mkdir -p $TEMP
mkdir -p $TEMP/control

for BOARD in $BOARDS; do 
  printf " - $BOARD "
  if [ -r $TOP/config/$BOARD ]; then printf "(ok)"; else printf "(not found)"; fi
  printf "\n"
  rm -f $TEMP/control/$BOARD.at
done

printf "\n"

printf "Detecting test releases...\n"
RELEASES="images/abuild-LinuxBIOSv2-* images/manual-LinuxBIOSv2-*"
for RELEASE in $RELEASES; do
  R=`echo $RELEASE |cut -f3- -d\-`
  printf "\n  release $R\n"
  for BOARD in $BOARDS; do
    if [ -r $TOP/config/$BOARD ]; then
      printf "    mainboard $BOARD:\n"
      if [ ! -d $RELEASE/$BOARD ]; then
        printf "      - no images.\n"
        continue
      fi
      IMAGES="$RELEASE/$BOARD/*.rom"
      for IMAGE in $IMAGES; do
        IMAGE="${IMAGE/images\//}"
      	DIR=`dirname $IMAGE`
        printf "      - $IMAGE"
	if [ -r $TEMP/$DIR/completed ]; then
	  printf " (done)"
	else 
	if [ -d $TEMP/$DIR ]; then
	  printf " (queued)"
	else
	
	  printf " queueing..."
	  # create directory for output
	  mkdir -p $TEMP/$DIR
	  
	  if [ ! -f $TEMP/control/$BOARD.at ]; then 
	    echo "#!/bin/bash" > $TEMP/control/$BOARD.at
	  fi
	  echo "echo \"Processing image $IMAGE...\"" >> $TEMP/control/$BOARD.at
	  echo "$TOP/bin/run-tests-on-image.sh images/$IMAGE $TOP &>$TEMP/$DIR/run.out || echo \"An error happened with $IMAGE\"" >> $TEMP/control/$BOARD.at 
	  printf "ok."
	fi
	fi
	printf "\n"
      done
    fi
  done
done
		       
printf "\n"

echo "Starting queues..."
for BOARD in $BOARDS; do 
  printf " - $BOARD "
  if [ -r  $TEMP/control/$BOARD.at ]; then 
    chmod 755 $TEMP/control/$BOARD.at
    echo "$TEMP/control/$BOARD.at &> $TEMP/control/$BOARD.at.run" | at now &> /dev/null
    printf "(ok)"
  else 
    printf "(not found)"
  fi
  printf "\n"
done

printf "\n"
