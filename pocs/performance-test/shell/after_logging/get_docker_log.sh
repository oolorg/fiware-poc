#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

for i in `docker ps -a --format '{{.Names}}'`
do
   sudo cp -p `sudo docker inspect ${i} | grep LogPath | cut -d "\"" -f 4` ${logpath}docker_log_${i}.log
done
