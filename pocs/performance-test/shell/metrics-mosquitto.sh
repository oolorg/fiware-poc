sudo docker exec mosquitto-demo /usr/bin/mosquitto_sub -t \$SYS/broker/publish/messages/received -C 1 >> metrics-mosquitto.log
sudo docker exec mosquitto-demo /usr/bin/mosquitto_sub -t \$SYS/broker/publish/messages/sent -C 1 >> metrics-mosquitto.log
