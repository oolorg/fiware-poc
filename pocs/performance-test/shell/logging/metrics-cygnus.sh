#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

while :
do
    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}metrics-cygnus-http-source.log
     curl -sS localhost:41414/metrics | jq '.["SOURCE.http-source"]'>> ${logpath}metrics-cygnus-http-source.log
    echo "" >>${logpath}metrics-cygnus-http-source.log

    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}metrics-cygnus-mongo-channel.log
     curl -sS localhost:41414/metrics | jq '.["CHANNEL.mongo-channel"]'>> ${logpath}metrics-cygnus-mongo-channel.log
    echo "" >>${logpath}metrics-cygnus-mongo-channel.log

    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}metrics-cygnus-sth-channel.log
     curl -sS localhost:41414/metrics | jq '.["CHANNEL.sth-channel"]'>> ${logpath}metrics-cygnus-sth-channel.log
    echo "" >>${logpath}metrics-cygnus-sth-channel.log

    sleep 1
done
