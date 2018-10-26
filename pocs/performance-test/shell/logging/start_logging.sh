#?/bin/bash

./metrics-mosquitto.sh
./get_host_metrics.sh 1 1140
./statistics-orion.sh
./subscription-orion.sh
./01-get_fiware_cpu_docker_stats.sh &
./metrics-cygnus.sh &
./metrics-orion.sh &
