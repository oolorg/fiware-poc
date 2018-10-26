#!/bin/bash
device=$1

for i in `seq 1 ${device}`
do
   /usr/bin/curl -sX GET "http://localhost:8666/STH/v1/contextEntities/type/sensor/id/sensor:device${i}/attributes/messages?lastN=100000" -H 'fiware-service:ool' -H 'fiware-servicepath:/' | python3 -m json.tool | grep apikey/device >> comet-result.log
done
