NUMBER_OF_CONTAINERS=$1

id=0

for i in `seq 1 $1`
do
    docker run -d -e HOST=192.168.28.10 -e PUB_INTERVAL=5 -e DEVICE_ID=device${id} -e TOPIC=/apikey/device${id}/attrs --name device${id} pub &
    id=`expr $id + 1`
done
