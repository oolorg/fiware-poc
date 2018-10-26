#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

while :
do
    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}metrics-orion.log
    curl -sS localhost:1026/admin/metrics | jq '.services.ool.subservs."root-subserv"' >>  ${logpath}metrics-orion.log
    echo "" >>  ${logpath}metrics-orion.log

    sleep 1
done
