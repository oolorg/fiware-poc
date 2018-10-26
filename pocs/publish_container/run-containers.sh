BROKER_HOST=$1
NUMBER_OF_CONTAINERS=$2
SEND_INTERVAL=$3
MESSAGE_NUM=$4

for i in `seq -f %05g ${NUMBER_OF_CONTAINERS}`
do
    docker run -d --net=host \
      -e BROKER_HOST=${BROKER_HOST} \
      -e USERNAME=iota \
      -e PASSWORD=password \
      -e APIKEY=apikey \
      -e VM_ID=vm1 \
      -e DEVICE_ID=device${i} \
      -e SEND_INTERVAL=${SEND_INTERVAL} \
      -e MESSAGE_NUM=${MESSAGE_NUM} \
      --name device${i} \
      --log-driver=syslog \
      dummy_device
done

