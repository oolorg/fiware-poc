#!/bin/bash

for i in `docker ps --format '{{.Names}}'`
do
    echo ${i}
    cat fiware-cpu.log | grep " ${i} " | while read line
    do
        echo $line |awk -v 'OFS=:' '{print $3,$4,$7,$8,$10,$11,$13}' >>${i}.cpu
    done
done
