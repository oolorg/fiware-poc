#!/bin/bash

NUMBER_OF_CONTAINERS=$1

sudo kill -9 `ps -ef | grep 01-get_fiware_cpu_docker_stats.sh | grep -v "grep" | awk '{print $2}'`
sudo kill -9 `ps -ef | grep metrics-cygnus.sh | grep -v "grep" | awk '{print $2}'`
sudo kill -9 `ps -ef | grep metrics-orion.sh | grep -v "grep" | awk '{print $2}'`

../logging/metrics-mosquitto.sh
./08-get_fiware_cpu_docker_stats_shaping.sh
./copy_all_docker_logs.sh
./get_data_from_comet.sh ${NUMBER_OF_CONTAINERS}
