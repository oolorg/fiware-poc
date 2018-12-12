BROKER_HOST=$1
NUMBER_OF_CONTAINERS=$2
SEND_INTERVAL=$3
MESSAGE_NUM=$4
STARTUP_TIME=$5

for i in `seq ${NUMBER_OF_CONTAINERS}`
do
   docker run -d --net=host \
    -e BROKER_HOST=${BROKER_HOST} \
    -e USERNAME=iota \
    -e PASSWORD=password \
    -e APIKEY=apikey \
    -e VM_ID=vm1 \
    -e DEVICE_ID=device`printf %05g ${i}` \
    -e SEND_INTERVAL=${SEND_INTERVAL} \
    -e MESSAGE_NUM=${MESSAGE_NUM} \
    -e STARTUP_INTERVAL=`echo "scale=2; ${STARTUP_TIME}/${NUMBER_OF_CONTAINERS}*${i}+5" | bc` \
    --name device`printf %05g ${i}` \
    --log-driver=syslog \
    dummy_device_startup_interval
done

./get-syslog.sh &
