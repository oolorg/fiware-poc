#!/bin/bash

logpath=../../log/

while :
do
    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}fiware_cpu_docker_stats.log;docker stats --no-stream >> ${logpath}fiware_cpu_docker_stats.log;echo "" >> ${logpath}fiware_cpu_docker_stats.log
done

