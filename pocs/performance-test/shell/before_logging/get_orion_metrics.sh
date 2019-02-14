#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

while :
do
    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}orion_metrics.log
    curl -sS localhost:1026/admin/metrics | jq '.services.ool.subservs."root-subserv"' >>  ${logpath}orion_metrics.log
    echo "" >>  ${logpath}orion_metrics.log

    sleep 1
done
