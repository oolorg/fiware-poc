NUMBER_OF_CONTAINERS=$1
interval=$2
max=$3
id=$4

tail -f /var/log/syslog > `hostname`-syslog.log &

for i in `seq 1 $1`
do
    docker run -d --net=host -e HOST=192.168.28.10 -e PUB_INTERVAL=${interval} -e DEVICE_ID=device${i} -e TOPIC=/apikey/device${i}/attrs -e MAX=${max} --name device${i} --log-driver=syslog pub2
    id=`expr $id + 1`
done

while [ $((`/usr/bin/docker ps|wc|awk '{print $1}'`)) -gt 1 ]
do    
    sleep 10
done

for i in `ps -aef | grep tail |awk '{print $2}'`
do
    kill -9 ${i}
done

