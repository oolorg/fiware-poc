logpath=${TEST_HOME}/pocs/performance-test/log/

# 擬似デバイスの数
# numberOfDevice=500
numberOfDevice=$1
# 集計間隔
#interval="1 hours"
interval="5 minutes"
#interval="30 minutes"

# 最初のデータの時刻を取得する
startDate=`curl -sX GET "http://localhost:8666/STH/v1/contextEntities/type/sensor/id/sensor:vm1device00001/attributes/messages?hOffset=0&hLimit=1" -H 'fiware-service:ool' -H 'fiware-servicepath:/' | jq -r .contextResponses[].contextElement.attributes[].values[].recvTime`
#echo ${startDate}

dateFrom=`date -d "${startDate}" +%Y-%m-%dT%H:%M:%SZ`
#dateTo=`date -d "${dateFrom} 1 minutes" +%Y-%m-%dT%H:%M:%SZ`
dateTo=`date -d "${dateFrom} ${interval}" +%Y-%m-%dT%H:%M:%SZ`

while :
do
    # 一定時間内に蓄積されたデータ数の総数を計算
    sum=0
    for id in `seq -f %05g 1 ${numberOfDevice}`
    do
        count=`curl -sX GET "http://localhost:8666/STH/v1/contextEntities/type/sensor/id/sensor:vm1device${id}/attributes/messages?lastN=5000&dateFrom=${dateFrom}&dateTo=${dateTo}" -H 'fiware-service:ool' -H 'fiware-servicepath:/' | jq -c '.contextResponses[].contextElement.attributes[].values | length'`
        sum=`expr ${sum} + ${count}`
    done
    echo ${dateFrom},${dateTo},${sum} >> ${logpath}${numberOfDevice}-throughput.csv

    dateFrom=`date -d "${dateTo}" +%Y-%m-%dT%H:%M:%SZ`
    dateTo=`date -d "${dateTo} ${interval}" +%Y-%m-%dT%H:%M:%SZ`
    if [ ${sum} -eq 0 ]; then
        break
    fi
done
