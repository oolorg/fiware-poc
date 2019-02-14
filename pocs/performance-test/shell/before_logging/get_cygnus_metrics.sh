#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

while :
do
    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}cygnus_metrics_http_source.log
     curl -sS localhost:41414/metrics | jq '.["SOURCE.http-source"]'>> ${logpath}cygnus_metrics_http_source.log
    echo "" >>${logpath}cygnus_metrics_http_source.log

    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}cygnus_metrics_mongo_channel.log
     curl -sS localhost:41414/metrics | jq '.["CHANNEL.mongo-channel"]'>> ${logpath}cygnus_metrics_mongo_channel.log
    echo "" >>${logpath}cygnus_metrics_mongo_channel.log

    date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}cygnus_metrics_sth_channel.log
     curl -sS localhost:41414/metrics | jq '.["CHANNEL.sth-channel"]'>> ${logpath}cygnus_metrics_sth_channel.log
    echo "" >>${logpath}cygnus_metrics_sth_channel.log

    sleep 1
done
