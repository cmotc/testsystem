# test script for powerswitch.exp

# switch on all power ports
./powerswitch.exp on 1:4

sleep 2

# switch off all of them
./powerswitch.exp off 1:4

# now have each relay click for us seperately
for i in 1 2 3 4; do
  echo watch plug $i
  ./powerswitch.exp on $i
  sleep 1
  ./powerswitch.exp off $i
done

