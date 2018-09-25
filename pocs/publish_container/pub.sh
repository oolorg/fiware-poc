#!/bin/sh

count=0

while :
do
    mosquitto_pub -h ${HOST} -u ${USERNAME} -P ${PASSWORD} -t ${TOPIC} -m "{\"m\":\"/apikey/${DEVICE_ID}/seq/${count}\"}"
    count=`expr $count + 1`
    sleep ${PUB_INTERVAL}
done
