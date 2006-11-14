#!/bin/bash
#
# This script is for informational and debugging purposes. 
# It lists all available mainboards and images in an easily 
# readable way and lists which tests need executing and 
# which are already done.
#

TOP=`pwd`
TEMP=$TOP/results
printf "\n"

printf "Detecting Boards..."
BOARDS=`find images/ -type d |grep -v .svn|cut -f3 -d/|sort -u|grep -v  ^\\.$ |grep -v ^$`
printf "ok.\n"
for BOARD in $BOARDS; do 
  printf " - $BOARD "
  if [ -r $TOP/config/$BOARD ]; then 
    printf "(ok)"; 
  else 
    printf "(not found)"; 
  fi
  printf "\n"
done
printf "\n"

completed=1;

printf "Detecting test releases...\n"

RELEASES="images/abuild-LinuxBIOSv2-* images/manual-LinuxBIOSv2-*"

for RELEASE in $RELEASES; do
  RELEASE=${RELEASE/images\//}
  R=`echo $RELEASE |cut -f3- -d\-`

  printf "\n  release $R\n"
  for BOARD in $BOARDS; do
    if [ -r $TOP/config/$BOARD ]; then
      printf "    mainboard $BOARD:\n"
      if [ ! -d images/$RELEASE/$BOARD ]; then
        printf "      - no images.\n"
        continue
      fi
      
      IMAGES="images/$RELEASE/$BOARD/*.rom"
      for IMAGE in $IMAGES; do
        printf "      - $IMAGE"
	
	if [ -r $TEMP/$RELEASE/$BOARD/completed ]; then
	  printf " (done)\n"
	else if [ -r $TEMP/$RELEASE/$BOARD/running ]; then
	  printf " (in progress)\n"
	  completed=0;
	else if [ -r $TEMP/$RELEASE/$BOARD ]; then
	  printf " (in queue)\n"
	  completed=0;
	else
	  printf " (not done)\n"
	  # if an image is not done this can have two reasons:
	  # 1. the testsuite did not run yet
	  # 2. it was manually deselected
	  # to handle case two correctly we assume that this
	  # image is not needed for or not wanted in the report.
	  
	  # NOTE: since deselection is not possible (and might just
	  # be useless) we consider this case incomplete, too:
	  completed=0;
	fi
	fi
	fi
      done
    fi
  done
done

printf "\n"

if [ $completed -ne 1 ]; then
   printf "NOTE: Test suite is still running. Try again later.\n\n"
   exit 0
fi

printf "Packing results file... "
tar cjf LinuxBIOS-results.tar.bz2 -C $TEMP . 2>&1
printf "ok\n"

printf "Uploading results file... "
curl -s -f -o upload-date.txt -F "results=@LinuxBIOS-results.tar.bz2" \
"http://snapshots.linuxbios.org/deployment/gather.php";
printf "ok\n"

printf "Upload Log: \n"
cat upload-date.txt

printf "Upload completed in ${SECONDS}s\n"

