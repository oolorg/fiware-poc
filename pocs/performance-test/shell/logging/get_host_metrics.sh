#!/bin/bash

INTERVAL=$1
NUMBER_OF_COUNT=$2

sar -P ALL -o `hostname`-cpu.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &
sar -r -o `hostname`-mem.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &
sar -n DEV -o `hostname`-net.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &
sar -n EDEV -o `hostname`-enet.sardata ${INTERVAL} ${NUMBER_OF_COUNT} 1>/dev/null &

