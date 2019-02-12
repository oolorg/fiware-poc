#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

while :
do
    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}fiware_docker_stats.log;docker stats --no-stream >> ${logpath}fiware_docker_stats.log;echo "" >> ${logpath}fiware_docker_stats.log
done

