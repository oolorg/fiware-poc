NUMBER_OF_CONTAINERS=$1
interval=$2
id=$3

for i in `seq 1 $1`
do
    docker run -d --net=host -e HOST=192.168.28.10 -e PUB_INTERVAL=${interval} -e DEVICE_ID=device${id} -e TOPIC=/apikey/device${id}/attrs --name device${id} --log-driver=syslog pub &
    id=`expr $id + 1`
    sleep 1
done
