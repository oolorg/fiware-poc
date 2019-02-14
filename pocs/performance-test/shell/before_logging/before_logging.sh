#!/bin/bash

${TEST_HOME}/pocs/performance-test/shell/before_logging/get_mosquitto_metrics.sh
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_host_metrics.sh 1
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_orion_statictics.sh
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_orion_subscription.sh
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_veth.sh
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_fiware_docker_stats.sh &
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_cygnus_metrics.sh &
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_orion_metrics.sh &
${TEST_HOME}/pocs/performance-test/shell/before_logging/get_cygnus_stats.sh &
