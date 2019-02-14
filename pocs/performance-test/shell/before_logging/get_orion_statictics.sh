#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}orion_statistics.log
curl -sX GET 'http://localhost:1026/statistics' -H 'fiware-service:ool' -H 'fiware-servicepath:/'| python3 -m json.tool >>  ${logpath}orion_statistics.log
echo "" >>  ${logpath}orion_statistics.log
