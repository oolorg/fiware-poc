#!/bin/sh

count=0

for i in `seq 1 ${MAX}`
do
    mosquitto_pub -h ${HOST} -u ${USERNAME} -P ${PASSWORD} -t ${TOPIC} -i ${DEVICE_ID}_${count} -m "{\"m\":\"/apikey/${DEVICE_ID}/seq/${count}\"}" -d
    if [ $? = 0 ]; then
       echo "{\"succes\":\"/apikey/${DEVICE_ID}/seq/${count}\"}"
    else
       echo "{\"error\":\"/apikey/${DEVICE_ID}/seq/${count}\"}"
    fi
    count=`expr $count + 1`
    sleep ${PUB_INTERVAL}
done
