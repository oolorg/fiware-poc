#!/bin/bash

INTERVAL=$1
NUMBER_OF_COUNT=$2

logpath=${TEST_HOME}/pocs/performance-test/log/

sar -o ${logpath}`hostname`.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &

