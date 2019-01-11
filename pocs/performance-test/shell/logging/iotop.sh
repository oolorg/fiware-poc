#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

while :
do
    sudo iotop -b -t | head -n 20 >>  ${logpath}iotop.log
    echo "" >>  ${logpath}iotop.log

    sleep 1
done
