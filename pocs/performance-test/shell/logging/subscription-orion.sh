#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}subscription-orion.log
curl -sX GET 'http://localhost:1026/v2/subscriptions' -H 'fiware-service:ool' -H 'fiware-servicepath:/' | python3 -m json.tool >> ${logpath}subscription-orion.log
echo "" >> ${logpath}subscription-orion.log
