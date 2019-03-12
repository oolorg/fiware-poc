#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc

docker cp cygnus-demo:/gc.log ${TEST_HOME}/pocs/performance-test/log/cygnus-gc.log
