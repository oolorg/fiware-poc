#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc
NUMBER_OF_CONTAINERS=$1

sudo kill -9 `ps -ef | grep sar | grep -v "grep" | awk '{print $2}'`
sudo kill -9 `ps -ef | grep get_cygnus_metrics.sh | grep -v "grep" | awk '{print $2}'`
sudo kill -9 `ps -ef | grep get_fiware_docker_stats.sh | grep -v "grep" | awk '{print $2}'`

${TEST_HOME}/pocs/performance-test/shell/before_logging/get_mosquitto_metrics.sh
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_orion_subscription.sh

${TEST_HOME}/pocs/performance-test/shell/after_logging/get_docker_log.sh
${TEST_HOME}/pocs/performance-test/shell/after_logging/get_comet_data.sh ${NUMBER_OF_CONTAINERS}
${TEST_HOME}/pocs/performance-test/shell/after_logging/get_throughput.sh ${NUMBER_OF_CONTAINERS}

${TEST_HOME}/pocs/performance-test/shell/after_logging/get_cygnus_gclog.sh
docker cp cygnus-demo:/heap-dump.hprof ${TEST_HOME}/pocs/performance-test/log/cygnus-heap-dump.hprof &>/dev/null

if [ $? = 0 ];then
    echo "Cygnus OutOfMemoryError"
else
    echo "Not OutOfMemoryError"
fi
