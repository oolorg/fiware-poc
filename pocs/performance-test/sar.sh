#!/bin/bash

sar -P ALL -o `hostname`-cpu.sardata $1 $2 1>/dev/null &
sar -r -o `hostname`-mem.sardata $1 $2 1>/dev/null &
sar -n DEV -o `hostname`-net.sardata $1 $2 1>/dev/null &
sar -n EDEV -o `hostname`-enet.sardata $1 $2 1>/dev/null &

