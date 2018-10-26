#!/bin/bash

logpath=../performance-test/log/

tail -f /var/log/syslog > ${logpath}`hostname`-syslog.log &

while [ $((`/usr/bin/docker ps|wc|awk '{print $1}'`)) -gt 1 ]
do
    sleep 60
done

for i in `ps -aef | grep tail |awk '{print $2}'`
do
    kill -9 ${i}
done
