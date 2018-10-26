#!/bin/bash

logpath=../../log/

date "+%Y/%m/%d %H:%M:%S.%N" >> ${logpath}metrics-mosquitto.log
docker exec mosquitto-demo /usr/bin/mosquitto_sub -t \$SYS/broker/publish/messages/received -C 1 >> ${logpath}metrics-mosquitto.log
docker exec mosquitto-demo /usr/bin/mosquitto_sub -t \$SYS/broker/publish/messages/sent -C 1 >> ${logpath}metrics-mosquitto.log
echo "" >>${logpath}metrics-mosquitto.log
