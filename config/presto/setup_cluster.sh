#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS public DNS's
FIRST_LINE=true
NUM_WORKERS=0
while read line; do
  if [ "$FIRST_LINE" = true ]; then
    MASTER_DNS=$line
    SLAVE_DNS=()
    FIRST_LINE=false
  else
    SLAVE_DNS+=($line)
    NUM_WORKERS=$(echo "$NUM_WORKERS + 1" | bc -l)
  fi
done < tmp/$INSTANCE_NAME/public_dns

# Configure base Presto coordinator and workers
ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/presto/setup_single.sh $MASTER_DNS $NUM_WORKERS &
for dns in "${SLAVE_DNS[@]}"
do
  ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/presto/setup_single.sh $MASTER_DNS $NUM_WORKERS &
done

wait

# Configure Presto coordinator and workers
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/presto/config_coordinator.sh &
for dns in "${SLAVE_DNS[@]}"
do
  ssh -i $PEMLOC ubuntu@$dns 'bash -s' < config/presto/config_worker.sh &
done

wait

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/presto/setup_cli.sh

echo "Presto configuration complete!"
echo "NOTE: Presto versions after 0.86 require Java 8"
echo "777777777777777777777777777777777777777777777777777777777777
777777777777777777777777777777777777777777777777777777777777
777777777777777777777777777777777777777777777777777777777777
777777777777777777777777?..............777777777777777777777
777777777777777........7777777~...77777777777..7777777777777
77777777777...7777777777777777777777777.7777777..77777777777
77777777..~77.777777777777777777777777.77.777777..7777777777
7777777..777777.77777.7777777777777777.77.7777777..777777777
7777777.7777777777777.7777777777777777777.7.777777.777777777
777777..777777777777777777777777.......777777777777.77777777
77777..7777777......~77777777..777........7777777777..777777
777..77.777777..........:777..77....:7....77.7777777.7.77777
777.7.7.7777777777777..7777777.77777..777777.......7777..777
77...77=......7.77777..777777777777777......777.777..777..77
77..~77777.7...77777..77777777777777777777777....777.7777.77
777..7.777.7777777..77777777777..7....7777...77....7.7777.77
7777.7.77...777.77...77777....7..77777....77777.777..7.7..77
7777..777.....7777777...777777777....7777.777...77777.7..777
77777.777..7.7.....7777777........777777....7..777777..77777
77777..7=..7.77.7777..7777.777777.7.......77..777777..777777
77777,.77........7777.7777.7777.......777.7..777777..7777777
77777=.77........................7.777777..77777777.77777777
77777..77.7.................777777.7777...77777777.777777777
77777.7777.?.7.77.777.77777.7777777.7..777777777..7777777777
77777.77777.....7..777.7777.7777.....777.77..7..=77777777777
77777.77777777..................77777.77..77..77777777777777
77777.77.777777777777777777777777.~77.777...7777777777777777
77777.77777777..777777777777..77.=7777..~7777777777777777777
77777.77777.7777777777777..7777777...77777777777777777777777
77777.7777777777777777777777777...77777777777777777777777777
777777..77777777777777777......77777777777777777777777777777
77777777...............:777777777777777777777777777777777777
777777777777777777777777777777777777777777777777777777777777
777777777777777777777777777777777777777777777777777777777777
777777777777777777777777777777777777777777777777777777777777"