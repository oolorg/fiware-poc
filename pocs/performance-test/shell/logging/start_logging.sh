#!/bin/bash

${TEST_HOME}/pocs/performance-test/shell/logging/metrics-mosquitto.sh
${TEST_HOME}/pocs/performance-test/shell/logging/get_host_metrics.sh 1 345600
${TEST_HOME}/pocs/performance-test/shell/logging/statistics-orion.sh
${TEST_HOME}/pocs/performance-test/shell/logging/subscription-orion.sh
${TEST_HOME}/pocs/performance-test/shell/logging/veth.sh
${TEST_HOME}/pocs/performance-test/shell/logging/01-get_fiware_cpu_docker_stats.sh &
${TEST_HOME}/pocs/performance-test/shell/logging/docker-stats.sh &
${TEST_HOME}/pocs/performance-test/shell/logging/metrics-cygnus.sh &
${TEST_HOME}/pocs/performance-test/shell/logging/metrics-orion.sh &
${TEST_HOME}/pocs/performance-test/shell/logging/stats-cygnus.sh &
${TEST_HOME}/pocs/performance-test/shell/logging/iotop.sh &
