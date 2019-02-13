#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc
NUMBER_OF_CONTAINERS=$1

sudo kill -9 `ps -ef | grep fiware_docker_stats.sh | grep -v "grep" | awk '{print $2}'`
sudo kill -9 `ps -ef | grep metrics-cygnus.sh | grep -v "grep" | awk '{print $2}'`
sudo kill -9 `ps -ef | grep metrics-orion.sh | grep -v "grep" | awk '{print $2}'`
sudo kill -9 `ps -ef | grep sar | grep -v "grep" | awk '{print $2}'`
sudo kill -9 `ps -ef | grep stats-cygnus.sh | grep -v "grep" | awk '{print $2}'`

${TEST_HOME}/pocs/performance-test/shell/logging/metrics-mosquitto.sh
${TEST_HOME}/pocs/performance-test/shell/logging/statistics-orion.sh
${TEST_HOME}/pocs/performance-test/shell/logging/subscription-orion.sh

${TEST_HOME}/pocs/performance-test/shell/cleanup/copy_all_docker_logs.sh
${TEST_HOME}/pocs/performance-test/shell/cleanup/comet-data.sh ${NUMBER_OF_CONTAINERS}
${TEST_HOME}/pocs/performance-test/shell/cleanup/calc.sh ${NUMBER_OF_CONTAINERS}

docker cp cygnus-demo:/gc.log ${TEST_HOME}/pocs/performance-test/log/cygnus-gc.log
docker cp cygnus-demo:/heap-dump.hprof ${TEST_HOME}/pocs/performance-test/log/cygnus-heap-dump.hprof
