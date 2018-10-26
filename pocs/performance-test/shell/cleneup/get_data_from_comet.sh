#!/bin/bash

device=$1

logpath=../../log/

for i in `seq -f %05g ${device}`
do
   curl -sX GET "http://localhost:8666/STH/v1/contextEntities/type/sensor/id/sensor:device${i}/attributes/messages?lastN=100000" -H 'fiware-service:ool' -H 'fiware-servicepath:/' | python3 -m json.tool | grep device_id >> ${logpath}comet-result.log
done
