#!/bin/bash

sar -P ALL -o cpu.sardata $1 $2 1>/dev/null &
sar -r -o mem.sardata $1 $2 1>/dev/null &
sar -n DEV -o net.sardata $1 $2 1>/dev/null &
sar -n EDEV -o enet.sardata $1 $2 1>/dev/null &

