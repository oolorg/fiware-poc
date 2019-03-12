#!/bin/bash

BROKER_HOST=$1
NUMBER_OF_CONTAINERS=$2
SEND_MESSAGE_INTERVAL=$3
TEST_TIME=$4
MESSAGE_SENDING_START_INTERVAL=$5
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
    -e SEND_MESSAGE_INTERVAL=${SEND_MESSAGE_INTERVAL} \
    -e MESSAGE_NUM=$(((${TEST_TIME}+${NUMBER_OF_CONTAINERS}*${MESSAGE_SENDING_START_INTERVAL})/${SEND_MESSAGE_INTERVAL})) \
    -e WAIT_TIME_TO_SEND_MESSAGE=$((${MESSAGE_SENDING_START_INTERVAL}*${i})) \
    -e DATA_TYPE=${DATA_TYPE} \
    --name device`printf %05g ${i}` \
    --log-driver=syslog \
    dummy_device &>/dev/null
done

# 32400は9時間の秒換算(UTCをJSTに変換するために使用)
EXPECTED_FINISH_TIME=$((${NUMBER_OF_CONTAINERS}*${MESSAGE_SENDING_START_INTERVAL}*2+${TEST_TIME}+32400))

echo "Number of containers"
echo $((`docker ps |wc -l`-1))
echo ""
echo "Expected finish time"
date --date "${EXPECTED_FINISH_TIME} seconds" "+%m/%d %H:%M:%S"
echo ""
echo "Numebr of messages sent by one device"
echo $(((${TEST_TIME}+${NUMBER_OF_CONTAINERS}*${MESSAGE_SENDING_START_INTERVAL})/${SEND_MESSAGE_INTERVAL}))
echo ""
echo "Number of messages sent by all devices"
echo $(((${TEST_TIME}+${NUMBER_OF_CONTAINERS}*${MESSAGE_SENDING_START_INTERVAL})/${SEND_MESSAGE_INTERVAL}*${NUMBER_OF_CONTAINERS}))
