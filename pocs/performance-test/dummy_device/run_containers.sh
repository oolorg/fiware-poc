#!/bin/bash

BROKER_HOST=$1
NUMBER_OF_CONTAINERS=$2
SEND_INTERVAL=$3
MESSAGE_NUM=$4
STARTUP_TIME=$5
DATA_TYPE=$6

for i in `seq ${NUMBER_OF_CONTAINERS}`
do
   docker run -d --net=host \
    -e BROKER_HOST=${BROKER_HOST} \
    -e USERNAME=iota \
    -e PASSWORD=password \
    -e APIKEY=apikey \
    -e VM_ID=vm1 \
    -e DEVICE_ID=device`printf %05g ${i}` \
    -e SEND_INTERVAL=${SEND_INTERVAL} \
    -e MESSAGE_NUM=${MESSAGE_NUM} \
    -e STARTUP_INTERVAL=`expr ${STARTUP_TIME} \* ${i}` \
    -e DATA_TYPE=${DATA_TYPE} \
    --name device`printf %05g ${i}` \
    --log-driver=syslog \
    dummy_device &>/dev/null
done

EXPECTED_FINISH_TIME=$((${NUMBER_OF_CONTAINERS}*${STARTUP_TIME}*2+${MESSAGE_NUM}+32400))

echo "Expected finish time"
date --date "${EXPECTED_FINISH_TIME} seconds" "+%m/%d %H:%M:%S"
