#!/bin/bash

export TEST_HOME=/home/user098/fiware-poc

NUMBER_OF_CONTAINERS=$1
SUBSCRIPTION_STATUS=$2

../before_logging/before_logging.sh

sleep 60

./01_create_service.sh

sleep 10

./02_create_device.sh ${NUMBER_OF_CONTAINERS}

sleep 20

if [ ${SUBSCRIPTION_STATUS} = "messages_timeinstant" ]; then
    ./03_create_subscription_messages_timeinstant.sh
elif [ ${SUBSCRIPTION_STATUS} = "messages" ]; then
    ./03_create_subscription_messages.sh
else
    echo "error subscription"
fi

sleep 60

mosquitto_pub -h localhost -u iota -P password -t /start -m 1
