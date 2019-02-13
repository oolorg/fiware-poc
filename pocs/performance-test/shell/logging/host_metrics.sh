#!/bin/bash

INTERVAL=$1

logpath=${TEST_HOME}/pocs/performance-test/log/

sar -o ${logpath}`hostname`.sardata ${INTERVAL} 1>/dev/null &

