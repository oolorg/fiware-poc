#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

for i in `docker ps --format '{{.Names}}'`
do
    echo ${i}
    cat ${logpath}fiware_docker_stats.log | grep " ${i} " | while read line
    do
        echo $line |awk -v 'OFS=,' '{print $3,$4,$7}' >>${logpath}docker_stats_${i}.log
    done
done
