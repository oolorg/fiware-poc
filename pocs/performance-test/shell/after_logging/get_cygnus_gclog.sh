#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc
NUMBER_OF_CONTAINERS=$1

docker cp cygnus-demo:/gc.log ${TEST_HOME}/pocs/performance-test/log/cygnus-gc.log
