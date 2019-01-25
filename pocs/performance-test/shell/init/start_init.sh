#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc

../logging/start_logging.sh

sleep 300

./01-create-service.sh

sleep 10

./02-create-device.sh 1

sleep 20

./03-create-subscription.sh

sleep 300

# ../logging/start_logging.sh
#
# sleep 60

mosquitto_pub -h localhost -u iota -P password -t /start -m 1
