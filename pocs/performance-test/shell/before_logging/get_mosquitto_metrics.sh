#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}mosquitto_metrics.log
echo "received messages" >> ${logpath}mosquitto_metrics.log
docker exec mosquitto-demo /usr/bin/mosquitto_sub -t \$SYS/broker/publish/messages/received -C 1 >> ${logpath}mosquitto_metrics.log
echo "sent messages" >> ${logpath}mosquitto_metrics.log
docker exec mosquitto-demo /usr/bin/mosquitto_sub -t \$SYS/broker/publish/messages/sent -C 1 >> ${logpath}mosquitto_metrics.log
echo "" >>${logpath}mosquitto_metrics.log
