#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

while :
do
    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}cygnus_stats.log
     curl -sS http://localhost:5080/v1/stats | jq . >> ${logpath}cygnus_stats.log
    echo "" >>${logpath}cygnus_stats.log

    sleep 1
done
