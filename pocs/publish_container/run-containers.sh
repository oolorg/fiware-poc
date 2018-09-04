NUMBER_OF_CONTAINERS=$1

id=0

for i in `seq 1 $1`
do
    docker run -d -e HOST=172.18.0.1 -e PUB_INTERVAL=5 -e DEVICE_ID=device${id} --name device${id} pub &
    id=`expr $id + 1`
done
