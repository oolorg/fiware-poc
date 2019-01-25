#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc

../logging/start_logging.sh

sleep 5

./01-create-service.sh

sleep 5

./02-create-device.sh 10

sleep 5

./03-create-subscription.sh

sleep 5

# ../logging/start_logging.sh
#
# sleep 60

mosquitto_pub -h localhost -u iota -P password -t /start -m 1
