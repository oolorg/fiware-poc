#!/bin/bash

INTERVAL=$1
NUMBER_OF_COUNT=$2

logpath=${TEST_HOME}/pocs/performance-test/log/

sar -o ${logpath}`hostname`-cpu.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &

# sar -P ALL -o ${logpath}`hostname`-cpu.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &
# sar -r -o ${logpath}`hostname`-mem.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &
# sar -n DEV -o ${logpath}`hostname`-net.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &
# sar -n EDEV -o ${logpath}`hostname`-enet.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &

