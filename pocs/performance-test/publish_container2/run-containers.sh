NUMBER_OF_CONTAINERS=$1
interval=$2
max=$3
id=$4


for i in `seq 1 $1`
do
    docker run -d --net=host -e HOST=192.168.28.10 -e PUB_INTERVAL=${interval} -e DEVICE_ID=device${i} -e TOPIC=/apikey/device${i}/attrs -e MAX=${max} --name device${i} --log-driver=syslog pub2
    id=`expr $id + 1`
done
