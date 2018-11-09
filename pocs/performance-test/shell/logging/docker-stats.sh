#!/bin/bash

logpath=${TEST_HOME}/pocs/performance-test/log/

curl -sSX GET localhost:2376/containers/mongodb-comet-demo/stats >> ${logpath}docker-stats.log &    


