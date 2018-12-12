#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

while :
do
    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}stats-cygnus.log
     curl -sS http://localhost:5080/v1/stats | jq . >> ${logpath}stats-cygnus.log
    echo "" >>${logpath}stats-cygnus.log

    sleep 1
done
