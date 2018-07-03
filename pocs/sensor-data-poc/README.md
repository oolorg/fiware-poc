# センサーデータとFIWAREの検証メモ

# 目次

* [1.データ蓄積](#1データ蓄積)
    * [1.1.目的](#11目的)
    * [1.2.ゴール](#12ゴール)
    * [1.3.環境構築](#13環境構築)
    * [1.4.動作確認](#14動作確認)
* [2.可視化](#2可視化)
    * [2.1.目的](#21目的)
    * [2.2.ゴール](#22ゴール)
    * [2.3.事前調査](#23事前調査)
    * [2.4.環境構築](#24環境構築)
    * [2.5.動作確認](#25動作確認)
* [3.センサーデバイス操作、管理](#3センサーデバイス操作、管理)
    * [3.1.目的](#31目的)
    * [3.2.ゴール](#32ゴール)
    * [3.3.事前調査](#33事前調査)
    * [3.4.測定値の取得](#34測定値の取得)
    * [3.5.デバイス側をトリガーとしたorionからの設定の取得](#35デバイス側をトリガーとしたorionからの設定の取得)
    * [3.6.orionAPIをトリガーとしたデバイスへのコマンド発行と結果取得](#36orionAPIをトリガーとしたデバイスへのコマンド発行と結果取得)
* [4.参考情報](#4参考情報)
    * [4.1.API情報](#41API情報)
    * [4.2.MongoDBのデータ](#42MongoDBのデータ)

---

## 1.データ蓄積

### 1.1.目的

- IoTプラットフォームとIoTデバイスを使用した、データ蓄積の流れを確認し、ノウハウを蓄積する

--

### 1.2.ゴール

- IoTデバイスからIoTプラットフォームへのセンサーデータの蓄積を確認する
- CometのAPIを利用し履歴データを取得する

--

### 1.3.環境構築

--

#### Fiware

--

##### 前提

- docker install
- docker-compose install
- python3 install

--

##### 各コンポーネントの準備

--

###### MQTT broker (mosquitto)

- FIWAREからgitでMosquitoのDockerfileをクローンする

```bash
git clone https://github.com/telefonicaid/iotagent-node-lib.git
mv iotagent-node-lib/docker/Mosquitto .
rm -rf iotagent-node-lib
```

- Dockerfileを編集する

  `&& mv /etc/mosquitto/mosquitto.conf.example /etc/mosquitto/mosquitto.conf \`

の行を削除する

- Docker build

```bash
docker build -t mosquitto .
docker images
```

--

###### idas

- idasの設定ファイルを設定する必要がある
- 動かすことを優先としているため、Dockerfileの作成はせず、pullしたイメージを起動し、設定変更してcommitする
- 今回はMQTTとjsonを使用するため`iotagent-json`を使用する

```bash
docker pull fiware/iotagent-json:latest
docker images
```

- pullしたイメージを起動しログインする

```bash
docker run fiware/iotagent-json /bin/bash -d
docker ps
docker exec -it XXXXXXX /bin/bash
```

- config.jsファイルを編集する
    - 全コンポーネントが同一サーバに入っている構成を想定しているためlocalhostで名前解決するようなになっている
    - 今回はdockerで起動するため、名前解決できる名称を記載する必要がある。

```bash
/*
 * Copyright 2015 Telefonica Investigacion y Desarrollo, S.A.U
 *
 * This file is part of iotagent-json
 *
 * iotagent-json is free software: you can redistribute it and/or
 * modify it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * iotagent-json is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public
 * License along with iotagent-json.
 * If not, seehttp://www.gnu.org/licenses/.
 *
 * For those usages not covered by the GNU Affero General Public License
 * please contact with::[contacto@tid.es]
 */
var config = {};

config.mqtt = {
    host: 'localhost',
    port: 1883,
    thinkingThingsPlugin: true,
    qos: 0,
    retain: false
};

config.iota = {
    logLevel: 'DEBUG',
    timestamp: true,
    contextBroker: {
        host: 'orion',
        port: '1026'
    },
    server: {
        port: 4041
    },
    deviceRegistry: {
        type: 'mongodb'
    },
    mongodb: {
        host: 'mongodb',
        port: '27017',
        db: 'iotagentjson'
    },
    types: {},
    service: 'howtoService',
    subservice: '/howto',
    providerUrl: 'http://idas:4041',
    deviceRegistrationDuration: 'P1M',
    defaultType: 'Thing',
    defaultResource: '/iot/json'
};

config.configRetrieval = true;
config.defaultKey = '1234';
config.defaultTransport = 'MQTT';

module.exports = config;
```

- 設定変更したdockerコンテナからimageを作成する

```bash
docker ps
docker commit XXXXXXXXXX fiware/iotagent-json
docker images
```

- docker-composeのファイル

```yaml- Mosquittoでは環境変数としてパスワー
version: '2'
services:
  mongodb:
    image: mongo:3.2
    container_name: mongodb
    expose:
        - "27017"
    command: --smallfiles

  orion:
    image: fiware/orion:latest
    container_name: orion
    depends_on:
        - mongodb
    expose:
        - "1026"
    ports:
        - "1026:1026"
    command: -dbhost mongodb

  idas:
    image: fiware/iotagent-json:latest
    container_name: idas
    depends_on:
        - mosquitto
    expose:
        - "4041"
    ports:
        - "4041:4041"
    environment:
        - IOTA_MQTT_HOST=mosquitto
        - IOTA_MQTT_PORT=1883
        - IOTA_MQTT_USERNAME=iota
        - IOTA_MQTT_PASSWORD=password

  mosquitto:
    image: mosquitto
    container_name: mosquitto
    expose:
        - "1883"
    ports:
        - "1883:1883"
    environment:
        - IOT_PASS=password

  cygnus:
    image: fiware/cygnus-ngsi
    container_name: cygnus
    depends_on:
        - mongodb
    expose:
        - "5050"
    environment:
        - CYGNUS_MONGO_HOSTS=mongodb:27017

  comet:
    image: fiware/sth-comet
    container_name: comet
    depends_on:
        - mongodb
    expose:
        - "8666"
    ports:
        - "8666:8666"
    environment:
        - STH_HOST=0.0.0.0
        - DEFAULT_SERVICE=myhome
        - DEFAULT_SERVICE_PATH=/environment
        - DB_URI=mongodb:27017
        - LOGOPS_LEVEL=DEBUG
```

--

#### センサーデバイス

- センサーデバイスとしてRasberryPiを使用する
- 今回はセンサーデータをランダムな数値で擬似する
- cronで定期的に1分おきにMQTTパブリッシュできることを確認する

--

##### MQTTクライアントのインストール

- MQTTを送信する手段としてpaho python clientを使用する
  - インストール方法
    - http://www.eclipse.org/paho/clients/python/
  - サンプルプログラムとソース
    - https://github.com/eclipse/paho.mqtt.python/blob/master/src/paho/mqtt/publish.py
    - https://github.com/eclipse/paho.mqtt.python/blob/master/examples/publish_single.py
    - https://github.com/eclipse/paho.mqtt.python/blob/master/examples/publish_multiple.py

- インストール

```bash
pip install paho-mqtt
```

- サンプルプログラムを実行するとエラーが出るのでcontext.pyをプログラムと同一フォルダに配置する
  - https://github.com/eclipse/paho.mqtt.python/blob/master/examples/context.py

--

#### MQTTパブリッシュのサンプルプログラム

- 直書きした数値をパブリッシュするサンプルプログラム

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2014 Roger Light <roger@atchoo.org>
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Distribution License v1.0
# which accompanies this distribution.
#
# The Eclipse Distribution License is available at
#   http://www.eclipse.org/org/documents/edl-v10.php.
#
# Contributors:
#     Roger Light - initial implementation

# This shows an example of using the publish.multiple helper function.

import context  # Ensures paho is in PYTHONPATH
import paho.mqtt.publish as publish
import paho.mqtt.client as paho


publish.single("/test/sensor02/attrs", payload="{\"humidity\": 77,\"happiness\": \"Not bad\"}", qos=0,retain=False, hostname="172.16.254.26", port=1883, client_id="", keepalive=60, will=None,  auth = {'username':"iota", 'password':"password"}, tls=None, protocol=paho.MQTTv311, transport="tcp" )

```

- ランダムな数値をパブリッシュするサンプルプログラム
  - 10から100の間で10間隔の数字をランダムにパブリッシュする

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2014 Roger Light <roger@atchoo.org>
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Distribution License v1.0
# which accompanies this distribution.
#
# The Eclipse Distribution License is available at
#   http://www.eclipse.org/org/documents/edl-v10.php.
#
# Contributors:
#    Roger Light - initial implementation

# This shows an example of using the publish.multiple helper function.

import context  # Ensures paho is in PYTHONPATH
import paho.mqtt.publish as publish
import paho.mqtt.client as paho
import random

humidity_value = random.randrange(10,100,10)
happiness_value = "Not bat"

topic_value = "/test/sensor02/attrs"
payload_value = "{\"humidity\": \"%s\", \"happiness\": \"%s\"}" % (humidity_value,happiness_value)
qos_value = 0
retain_value = False
hostname_value = "172.16.254.26"
port_value = 1883
client_id_value = ""
keepalive_value = 60
will_value = None
auth_value =  {'username':"iota", 'password':"password"}
tls_value = None
protocol_value = paho.MQTTv311
transport_value = "tcp"

publish.single(topic_value, payload=payload_value, qos=qos_value,retain=retain_value, hostname=hostname_value, port=port_value, client_id=client_id_value, keepalive=keepalive_value, will=will_value,  auth = auth_value, tls=tls_value, protocol=protocol_value, transport=transport_value )
```

--

##### cronで定期実行

- クローンで上記のランダムな数値をパブリッシュするサンプルプログラムを定期実行する(1分毎)

`*/1 * * * * python /home/pi/fiware/test_mqtt_rundum.py`をcronに追加

--

### 1.4.動作確認

--

#### 起動(docker-compose up -d)

```bash
docker-compose up -d
```

--

#### デバイスの作成

- serviceを作成する

```bash
curl -X POST -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "services": [
      {
          "resource": "/iot/json",
          "apikey": "test",
          "type": "potSensor"
      }
    ]
}
' 'http://172.16.254.26:4041/iot/services'
```

- センサーデバイスを作成する

```bash
curl -X POST -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "devices": [
        {
            "device_id": "sensor02",
            "entity_name": "RosesPot",
            "entity_type": "potSensor",
            "attributes": [
              {
                "name": "humidity",
                "type": "percent"
              },
              {
                "name": "happiness",
                "type": "subjective"
              }
            ],
            "transport": "MQTT"
        }
    ]
}

' 'http://172.16.254.26:4041/iot/devices'
```

- mosquittoの機能を使用しMQTTパブリッシュを行うことで、Orionにデータを登録されることができる

```bash
docker ps
docker exec -it mosquitto /bin/bash
mosquitto_pub -d -t /test/sensor02/attrs -m '{"humidity": 76,"happiness": "Not bad"}' -u iota -P password
```

- OrionのAPIを使用し、Orionに登録されている情報を参照する(valueが追加されている確認)

リクエスト

```bash
curl -X GET http://172.16.254.26:1026/v2/entities/RosesPot -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" | python3 -m json.tool
```

レスポンス

```bash
{
    "id": "RosesPot",
    "type": "potSensor",
    "PING_info": {
        "type": "commandResult",
        "value": "36",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-07-01T12:50:09.376Z"
            }
        }
    },
    "PING_status": {
        "type": "commandStatus",
        "value": "OK",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-07-01T12:50:09.376Z"
            }
        }
    },
    "TimeInstant": {
        "type": "ISO8601",
        "value": "2018-07-01T15:46:01.00Z",
        "metadata": {}
    },
    "happiness": {
        "type": "subjective",
        "value": "Not bat",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-07-01T15:46:01.911Z"
            }
        }
    },
    "humidity": {
        "type": "percent",
        "value": "80",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-07-01T15:46:01.911Z"
            }
        }
    },
    "PING": {
        "type": "command",
        "value": "",
        "metadata": {}
    }
}
```

--

#### 履歴データの蓄積設定

- subscriptionの設定

```bash
curl -X POST -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "description": "CYGNUS Subscription",
    "subject": {
        "entities": [
            {
                "idPattern": ".*"
            }
        ]
    },
    "notification": {
        "http": {
            "url": "http://cygnus:5050/notify"
        },
        "attrsFormat": "legacy"
    },
    "expires": "2040-01-01T14:00:00.00Z"
}

' 'http://172.16.254.26:1026/v2/subscriptions'
```

- センサーからのデータを受け付けるため2,3分待つ

- mongodbに履歴情報が保存されているかの確認
  - _や/などが使われているため、通常の`db.xxx.find`コマンドは使用できないので注意

```
db.getCollection("sth_/environment_RosesPot_potSensor").find()
```

- cometAPIを使用しデータが保存されているかの確認

```bash
curl -X GET http://172.16.254.26:8666/STH/v1/contextEntities/type/potSensor/id/RosesPot/attributes/humidity?lastN=100 -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" | python3 -m json.tool
```

----

## 2.可視化

--

### 2.1.目的

- センサーデバイスからデータを収集、蓄積し、APIを利用し可視化する一連の流れを試す

--

### 2.2.ゴール

- Cometに蓄積されている履歴情報をCometのAPI外部ツールを使用しグラフを描画する

--

### 2.3.事前調査
- FIWAREのサイトに、[履歴情報を保存するバックエンドとして何が適しているか](https://github.com/telefonicaid/fiware-iot-stack/blob/master/docs/topics/which_historical_backend.md)が記載されている

- [日本語サイト](https://fiware-iot-stack.fisuda.jp/topics/which_historical_backend/index.html)

![履歴バックエンドについて](https://i.imgur.com/ITuVKCG.png)

- Cometの可視化ツールにはGrafanaと記載がある。しかし、以下とのこと
    - Cometで可視化ツールは提供されていない
    - Grafanaによる可視化についてはCometで提供されているものではない
    - CometにはREST APIがあるため、Grafanaと統合することが可能

- telefonicaが作成した[Cometで可視化するサンプルプログラム](https://github.com/telefonicaid/fiware-sth-graphs)を発見
- 今回は可視化を試すのが目的なので、上記プログラムを使用

--

### 2.4.環境構築

- docker上に環境を構築する

--

#### 必要コンポーネントインストール

- 今回は動かすことが目的なので、dockerにログインし手動で設定しcommitしてdockerimageを作成する

--

##### npm

- `apt install npm`

--

##### bower

- `npm install bower -g`

--

##### nginx

- `apt install nginx`

--

##### git

- `apt install git`

--

#### インストール

- `cd /var/www/html`
- `git clone https://github.com/telefonicaid/fiware-sth-graphs.git`
- `cd fiware-sth-graphs`
- `cp -p /var/www/html/fiware-sth-graphs/examples/jquery/* .`
- `bower install`
- `nginx`

--

#### 設定ファイル

- lineChart.html
    - ファイルのパス修正(htmlの中で読んでいるjsファイルをnginxのrootディレクトリにおいておかないといけない？？)

```html
<!doctype html>
<html>
    <head>
        <meta charset="utf-8"/>
        <script type="text/javascript" src="fiware-sth-graphs/bower_components/d3/d3.min.js"></script>
        <script type="text/javascript" src="fiware-sth-graphs/bower_components/nvd3/build/nv.d3.min.js"></script>
        <script type="text/javascript" src="fiware-sth-graphs/bower_components/jquery/dist/jquery.min.js"></script>

        <link href="fiware-sth-graphs/bower_components/nvd3/build/nv.d3.min.css" rel="stylesheet" type="text/css">
        <link href="lineChart.css" rel="stylesheet" type="text/css">
    </head>
    <body>
        <div id="chart">
            <svg></svg>
        </div>
        <script type="text/javascript" src="lineChart.js"></script>
    </body>
</html>
```

- lineChart.js
    - 接続先やヘッダー情報などはすべてファイルに記載しているため記載

```javascript

/**************************************
 * Data request and parser. This may be part of a model in MVC
 */
function loadData(callback) {
    var loadLocalData = false,     //change this if you want to perform a request to a real instance of sth-comet
    //change the urlParams and headers if you want to query your own entity data.
        urlParams = {
            dateFrom: '2018-06-21T08:29:01.872Z',
            dateTo: '2018-06-21T10:08:02.150Z',
            lastN: 30
        },
        headers = {
            'Fiware-Service': 'myhome',
            'Fiware-ServicePath': '/environment'
            //'X-Auth-Token': 'XXXXXXX'
        };

    if (loadLocalData) {
        return callback(rawTemperatureSamples); //return samples from samples.js
    } else {

        return $.ajax({
            method: 'GET',
            //Change this URL if you want to use your own sth-comet
            url: 'http://172.16.254.26:8666/STH/v1/contextEntities/type/potSensor/id/RosesPot/attributes/humidity',
            data: urlParams,
            headers: headers,
            dataType: 'json',
            success: function(data) {
                return callback(data);
            }
        });
    }
}

function parseSamples(values) {
    return values.map(function(point) {
        return {
            x: new Date(point.recvTime),
            y: point.attrValue
        }
    });
}

/**
 * draw data. This may be part of a controller code in MVC
 */
function loadGraph(data) {

    nv.addGraph(function() {
        var chart = nv.models.lineChart();
        chart.margin({
            top: 50,
            right: 150,
            bottom: 50,
            left: 50
        });
        chart.xAxis
            //.tickFormat(d3.time.format('%x %X'));
            .ticks(0)
            .tickFormat(function(d) {
                return d3.time.format('%x %X')(new Date(d))
            })
            .rotateLabels(45);

        chart.yAxis
            .tickFormat(d3.format(',.2f'));

//        d3.select('#chart svg')
        d3.select('#chart svg')
            .datum(data)
            .transition().duration(0)
            .call(chart);

        nv.utils.windowResize(chart.update);

        return chart;
    });
}

function init() {

    return loadData(function(data) {
        var values = data.contextResponses[0].contextElement.attributes[0].values,
            attrName = data.contextResponses[0].contextElement.attributes[0].name,
            samples = [
                {
                    key: attrName,
                    values: parseSamples(values)
                }
            ];
        loadGraph(samples);
    });
}

//execute the main method
init();
```

--

#### docker imageの作成

```bash
docker ps
docker commit XXXXXXXXXX graph
docker images
```

--

#### docker-composeファイルに追記
- docker-composeファイルに下記内容を追記する

```
  graph:
    image: graph
    container_name: graph
    depends_on:
        - comet
    expose:
        - "81"
    ports:
        - "81:81"
    command: /bin/sh -c "while true; do echo hello world; sleep 1; done"
```

--

### 2.5.動作確認

- nginxにアクセスすると下記グラフが表示される
    - グラフの情報はjsに直接指定している
    - 指定情報は以下
    - (dataFromからdataToの間で後ろから30行表示)
Fiware-Service: `myhome`
Fiware-ServicePath: `/environment`
url: `http://172.16.254.26:8666/STH/v1/contextEntities/type/potSensor/id/RosesPot/attributes/humidity`
dateFrom: `2018-06-21T08:29:01.872Z`
dateTo: `2018-06-21T10:08:02.150Z`
lastN: `30`

![グラフ](https://i.imgur.com/GGFiQQg.png)

- グラフ化している情報をcometのAPIから取得
    - グラフと比較すると一致していることがわかる
    - dockerのコンテナは、タイムゾーンがデフォルトでUTCで起動する。グラフの時刻が9時間ずれているのはJSTに変換されているからだと思われ る

リクエスト

```bash
curl -X GET 'http://172.16.254.26:8666/STH/v1/contextEntities/type/potSensor/id/RosesPot/attributes/humidity?dateFrom=2018-06-21T08:29:01.872Z&dateTo=2018-06-21T10:08:02.150Z&lastN=30' -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" | python3 -m json.tool
```

レスポンス

```
"recvTime": "2018-06-21T09:39:01.365Z",
"attrValue": "30"
"recvTime": "2018-06-21T09:40:01.648Z",
"attrValue": "90"
"recvTime": "2018-06-21T09:41:01.946Z",
"attrValue": "10"
"recvTime": "2018-06-21T09:42:02.245Z",
"attrValue": "20"
"recvTime": "2018-06-21T09:43:01.554Z",
"attrValue": "60"
"recvTime": "2018-06-21T09:44:01.859Z",
"attrValue": "70"
"recvTime": "2018-06-21T09:45:02.166Z",
"attrValue": "70"
"recvTime": "2018-06-21T09:46:01.473Z",
"attrValue": "80"
"recvTime": "2018-06-21T09:47:01.783Z",
"attrValue": "70"
"recvTime": "2018-06-21T09:48:02.085Z",
"attrValue": "40"
"recvTime": "2018-06-21T09:49:01.391Z",
"attrValue": "60"
"recvTime": "2018-06-21T09:50:01.696Z",
"attrValue": "30"
"recvTime": "2018-06-21T09:51:02.004Z",
"attrValue": "40"
"recvTime": "2018-06-21T09:52:01.304Z",
"attrValue": "80"
"recvTime": "2018-06-21T09:53:01.606Z",
"attrValue": "30"
"recvTime": "2018-06-21T09:54:01.920Z",
"attrValue": "90"
"recvTime": "2018-06-21T09:55:02.218Z",
"attrValue": "70"
"recvTime": "2018-06-21T09:56:01.514Z",
"attrValue": "20"
"recvTime": "2018-06-21T09:57:01.799Z",
"attrValue": "80"
"recvTime": "2018-06-21T09:58:02.099Z",
"attrValue": "30"
"recvTime": "2018-06-21T09:59:01.401Z",
"attrValue": "20"
"recvTime": "2018-06-21T10:00:01.707Z",
"attrValue": "20"
"recvTime": "2018-06-21T10:01:02.013Z",
"attrValue": "30"
"recvTime": "2018-06-21T10:02:01.321Z",
"attrValue": "20"
"recvTime": "2018-06-21T10:03:01.628Z",
"attrValue": "30"
"recvTime": "2018-06-21T10:04:01.936Z",
"attrValue": "70"
"recvTime": "2018-06-21T10:05:02.240Z",
"attrValue": "90"
"recvTime": "2018-06-21T10:06:01.542Z",
"attrValue": "20"
"recvTime": "2018-06-21T10:07:01.843Z",
"attrValue": "70"
"recvTime": "2018-06-21T10:08:02.150Z",
"attrValue": "20"
```

---

## 3.センサーデバイス操作、管理

--

### 3.1.目的

- FIWAREからセンサーデバイスの管理、制御の方法とノウハウの取得

--

### 3.2.ゴール

- IDAS(iotagent-json)の機能を理解する
- FIWAREからデバイスセンサーへの通知や操作が行えるかを調査/検証する
- FIWAREからデバイスセンサーの数や状態を把握できるかを調査/検証する
- (デバイスセンサーからFIWAREへ通知や操作が行えるかを調査/検証する)

--

### 3.3.事前調査

--

#### 参考URL

https://forge.fiware.org/plugins/mediawiki/wiki/fiware/index.php/FIWARE.ArchitectureDescription.IoT.Backend.DeviceManagement

https://fiware-iotagent-json.fisuda.jp/usermanual/index.html

https://github.com/Fiware/iot.IoTagent-JSON/blob/master/docs/stepbystep.md

https://github.com/telefonicaid/iotagent-node-lib/blob/23de297218f15f712f045856c6564f1e96ae8739/README.md

https://github.com/Fiware/tutorials.IoT-Agent/blob/master/README.ja.md

https://fiware-iotagent-json.fisuda.jp/usermanual/index.html#mqttbinding

--

#### IDASの機能(MQTTに関係した)

- 測定値の取得
- デバイスからのMQTTパブリッシュをトリガーとしたorionからの設定の取得
- orionAPIをトリガーとしたデバイスへのコマンド送信と結果取得

--

### 3.4.測定値の取得

- デバイスで取得した情報をIDAS(Fiware)に送信する機能を提供する
- センサーデバイスで下記トピックにパブリッシュすることでデータをFIWAREに送信することが可能

    - 複数の測定値を送信するトピック
`/{{api-key}}/{{device-id}}/attrs`
    - 単一の測定値を送信するトピック
`/{{api-key}}/{{device-id}}/attrs/<attributeName>`

--

### 3.5.デバイス側をトリガーとしたorionからの設定の取得

- デバイスが設定やOrionに格納されている値を取り出す機能を提供する
    - IDASの受け口(IDASのサブスクライブしているトピック) `/{{apikey}}/{{deviceid}}/configuration/commands`
        - IDASは上記トピックでサブスクライブしているため、上記トピックにパブリッシュすることでセンサー側からIDASへ要求することができる
        - ペイロードには下記2つの情報が含まれている必要がある。
            - type
                - デバイスの要求の種類(2種類)
                - subscription
                    - 指定したfieldsが変更された際に新しい値の通知を受ける設定を行う
                - configuration
                    - 本コマンド実行時に指定したfieldsの情報を取得する
            - fields
                - 数値を要求するentity

    - センサーの受け口(センサーがサブスクライブしているトピック)
 `/{{apikey}}/{{deviceid}}/configuration/values`
        - センサー側で上記トピックをサブスクライブしておくことで、IDASからの通知を受け取ることができる

--

### 3.6.orionAPIをトリガーとしたデバイスへのコマンド発行と結果取得
- センサーデバイスにコマンドの送信、実行結果を取得する機能を提供する
- デバイス作成時にcommandsを登録しておくと、orionのAPIで(orionでattributesを更新すると)デバイスにメッセージが送信可能

--

#### commandsの登録方法
- デバイス作成時のjsonにcommandsを記載する

```
curl -X POST -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d '{
    "devices": [
        {
            "device_id": "sensor02",
            "entity_name": "RosesPot",
            "entity_type": "potSensor",
            "attributes": [
              {
                "name": "humidity",
                "type": "percent"
              },
              {
                "name": "happiness",
                "type": "subjective"
              }
            ],
            "transport": "MQTT",
            "commands": [
              {
                "name": "PING",
                "type": "command"
              }
            ]
        }
    ]
}

' 'http://172.16.254.26:4041/iot/devices'
```

- orionにregistrationsが作成される

リクエスト

```
curl -X GET -s -S http://172.16.254.26:1026/v2/registrations -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" | python3 -m json.tool
```

レスポンス

```
[
    {
        "id": "5b3358b4dd8f6f146cef8b2c",
        "dataProvided": {
            "entities": [
                {
                    "id": "RosesPot",
                    "type": "potSensor"
                }
            ],
            "attrs": [
                "PING"
            ]
        },
        "provider": {
            "http": {
                "url": "http://idas:4041"
            },
            "supportedForwardingMode": "all",
            "legacyForwarding": true
        },
        "status": "active"
    }
]
```

- orionにentityが作成される
    - 以下のようにdevice作成時にcommandsを記載すると、`$(コマンド名)_info`、`$(コマンド名)_status`、`$(コマンド名)`のattributesが作成 される

リクエスト

```
curl -X GET -s -S http://172.16.254.26:1026/v2/entities/RosesPot -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" | python3 -m json.tool
```

レスポンス

```
{
    "id": "RosesPot",
    "type": "potSensor",
    "PING_info": {
        "type": "commandResult",
        "value": " ",
        "metadata": {}
    },
    "PING_status": {
        "type": "commandStatus",
        "value": "UNKNOWN",
        "metadata": {}
    },
    "TimeInstant": {
        "type": "ISO8601",
        "value": "2018-06-27T09:05:01.00Z",
        "metadata": {}
    },
    "happiness": {
        "type": "subjective",
        "value": "Not bat",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-06-27T09:05:01.661Z"
            }
        }
    },
    "humidity": {
        "type": "percent",
        "value": "10",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-06-27T09:05:01.661Z"
            }
        }
    },
    "PING": {
        "type": "command",
        "value": "",
        "metadata": {}
    }
}
```

--

#### コマンドの実行方法

- OrionのAPIを使用し、attributesを更新することで、`/{{apikey}}/{{deviceid}}/cmd`にメッセージが送信される

リクエスト

```
curl -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" http://172.16.254.26:1026/v1/updateContext -H "Content-Type: application/json" -d '{
    "updateAction": "UPDATE",
    "contextElements": [
        {
            "type": "potSensor",
            "isPattern": "false",
            "id": "RosesPot",
            "attributes": [
                {
                    "name": "PING",
                    "type": "command",
                    "value": {
                      "data":"63"
                    }
                }
            ]
        }
    ]
}' | python3 -m json.tool
```

レスポンス

```
{
    "contextResponses": [
        {
            "contextElement": {
                "type": "potSensor",
                "isPattern": "false",
                "id": "RosesPot",
                "attributes": [
                    {
                        "name": "PING",
                        "type": "command",
                        "value": ""
                    }
                ]
            },
            "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
            }
        }
    ]
}
```

--

#### センサーでのコマンドの受信方法

- センサー側で下記トピック`/{{apikey}}/{{deviceid}}/cmd`をサブスクライブしておくことで、orionのAPIでコマンドが更新された際に送信されるメッセージを受信することが可能
- サンプルプログラムは以下

```
#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2016 Roger Light <roger@atchoo.org>
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Distribution License v1.0
# which accompanies this distribution.
#
# The Eclipse Distribution License is available at
#   http://www.eclipse.org/org/documents/edl-v10.php.
#
# Contributors:
#    Roger Light - initial implementation

# This shows an example of using the subscribe.simple helper function.

import context  # Ensures paho is in PYTHONPATH
import paho.mqtt.subscribe as subscribe
import paho.mqtt.client as paho

topics = ['/test/sensor02/cmd']
# topics = ['#']
qos_value = 0
msg_count_value = 1
retained_value = False
hostname_value = "172.16.254.26"
port_value = 1883
client_id_value = ""
keepalive_value = 60
will_value = None
auth_value =  {'username':"iota", 'password':"password"}
tls_value = None
protocol_value = paho.MQTTv311
transport_value = "tcp"
clean_session_value = True

while True:
    m = subscribe.simple(topics, qos_value, msg_count_value, retained_value, hostname_value, port_value, client_id_value, keepalive_value, will_value, auth_value, tls_value, protocol_value, transport_value, clean_session_value)
    print(m.topic)
    print(m.payload)
```

- 受信情報の例は以下

```
/test/sensor02/cmd
{"PING":{"data":"777"}}
/test/sensor02/cmd
{"PING":{"data":"63"}}
```

--

#### センサーでのコマンド実行結果の送信方法

- コマンドの実行結果を以下トピック`/{{apikey}}/{{deviceid}}/cmdexe`に対してパブリッシュすることで、orionにコマンドの実行結果を登録することが可能
- 今回はコマンドの実行結果を手動でパブリッシュする

- サンプルプログラムは以下

```
#!/usr/bin/python
# -*- coding: utf-8 -*-

# Copyright (c) 2014 Roger Light <roger@atchoo.org>
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Distribution License v1.0
# which accompanies this distribution.
#
# The Eclipse Distribution License is available at
#   http://www.eclipse.org/org/documents/edl-v10.php.
#
# Contributors:
#    Roger Light - initial implementation

# This shows an example of using the publish.multiple helper function.

import context  # Ensures paho is in PYTHONPATH
import paho.mqtt.publish as publish
import paho.mqtt.client as paho


publish.single("/test/sensor02/cmdexe", payload="{\"PING\": \"36\"}", qos=0,retain=False, hostname="172.16.254.26", port=1883, client_id="", keepalive=60, will=None,  auth = {'username':"iota", 'password':"password"}, tls=None, protocol=paho.MQTTv311, transport="tcp" )
```

- コマンドの実行結果として{\"PING\": \"36\"}をパブリッシュした際にorionに登録されている情報は以下

リクエスト

```
curl -X GET -s -S http://172.16.254.26:1026/v2/entities/RosesPot -H "Fiware-Service: myhome" -H "Fiware-ServicePath: /environment" | python3 -m json.tool
```

レスポンス

```
{
    "id": "RosesPot",
    "type": "potSensor",
    "PING_info": {
        "type": "commandResult",
        "value": "36",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-06-27T09:10:36.756Z"
            }
        }
    },
    "PING_status": {
        "type": "commandStatus",
        "value": "OK",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-06-27T09:10:36.756Z"
            }
        }
    },
    "TimeInstant": {
        "type": "ISO8601",
        "value": "2018-06-27T09:10:36.00Z",
        "metadata": {}
    },
    "happiness": {
        "type": "subjective",
        "value": "Not bat",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-06-27T09:10:02.193Z"
            }
        }
    },
    "humidity": {
        "type": "percent",
        "value": "10",
        "metadata": {
            "TimeInstant": {
                "type": "ISO8601",
                "value": "2018-06-27T09:10:02.193Z"
            }
        }
    },
    "PING": {
        "type": "command",
        "value": "",
        "metadata": {}
    }
}
```

---

## 4.参考情報

--

### 4.1.API情報

--

#### IDAS
- [API](https://github.com/telefonicaid/iotagent-node-lib/blob/df2ca2fe96e75f1dceed6f33ed5e947b1354d9cc/doc/apiary/iotagent.apib)

--

#### Orion
- [API](https://swagger.lab.fiware.org/?url=https://raw.githubusercontent.com/Fiware/specifications/master/OpenAPI/ngsiv2/ngsiv2-openapi.json)

--

#### Cygnus

--

#### Comet

--

### 4.2.MongoDBのデータ

--

#### iotagentjson

```
> show collections
devices
groups
>
> db.groups.find()
{ "_id" : ObjectId("5b33587ba027d93802831242"), "subservice" : "/environment", "service" : "myhome", "type" : "potSensor", "apikey" : "test", "resource" : "/iot/json", "__v" : 0 }
>
> db.devices.find()
{ "_id" : ObjectId("5b3358b4a027d97cb4831243"), "transport" : "MQTT", "internalId" : null, "registrationId" : "5b3358b4dd8f6f146cef8b2c", "subservice" : "/environment", "service" : "myhome", "name" : "RosesPot", "type" : "potSensor", "id" : "sensor02", "creationDate" : ISODate("2018-06-27T09:28:20.406Z"), "subscriptions" : [ ], "commands" : [ { "object_id" : "PING", "type" : "command", "name" : "PING" } ], "active" : [ { "object_id" : "humidity", "type" : "percent", "name" : "humidity" }, { "object_id" : "happiness", "type" : "subjective", "name" : "happiness" } ], "__v" : 0 }
>
```

--

#### orion-myhome

```
> show collections
csubs
entities
registrations
>
>
> db.csubs.find()
{ "_id" : ObjectId("5b344f2cdd8f6f146cef8b2d"), "expiration" : NumberLong("2209039200"), "reference" : "http://cygnus:5050/notify", "custom" : false, "throttling" : NumberLong(0), "servicePath" : "/environment", "description" : "CYGNUS Subscription", "status" : "active", "entities" : [ { "id" : ".*", "isPattern" : "true" } ], "attrs" : [ ], "metadata" : [ ], "blacklist" : false, "conditions" : [ ], "lastNotification" : NumberLong(1530154796), "count" : NumberLong(1), "expression" : { "q" : "", "mq" : "", "geometry" : "", "coords" : "", "georel" : "" }, "format" : "JSON", "lastSuccess" : NumberLong(1530154797) }
>
>
> db.entities.find()
{ "_id" : { "id" : "RosesPot", "type" : "potSensor", "servicePath" : "/environment" }, "attrNames" : [ "humidity", "happiness", "PING_status", "PING_info", "TimeInstant" ], "attrs" : { "humidity" : { "type" : "percent", "creDate" : 1530091700, "modDate" : 1530091700, "value" : " ", "mdNames" : [ ] }, "happiness" : { "type" : "subjective", "creDate" : 1530091700, "modDate" : 1530091700, "value" : " ", "mdNames" : [ ] }, "PING_status" : { "type" : "commandStatus", "creDate" : 1530091700, "modDate" : 1530091700, "value" : "UNKNOWN", "mdNames" : [ ] }, "PING_info" : { "type" : "commandResult", "creDate" : 1530091700, "modDate" : 1530091700, "value" : " ", "mdNames" : [ ] }, "TimeInstant" : { "type" : "ISO8601", "creDate" : 1530091700, "modDate" : 1530091700, "value" : " ", "mdNames" : [ ] } }, "creDate" : 1530091700, "modDate" : 1530091700, "lastCorrelator" : "cbb43925-5552-4275-b900-364c5bb0cda5" }
>
>
> db.registrations.find()
{ "_id" : ObjectId("5b3358b4dd8f6f146cef8b2c"), "expiration" : NumberLong(1532683700), "servicePath" : "/environment", "format" : "JSON", "contextRegistration" : [ { "entities" : [ { "id" : "RosesPot", "type" : "potSensor" } ], "attrs" : [ { "name" : "PING", "type" : "command", "isDomain" : "false" } ], "providingApplication" : "http://idas:4041" } ] }
```

--

#### sth-comet

```
> show collections
sth_/environment_RosesPot_potSensor
sth_/environment_RosesPot_potSensor.aggr
>
>
>

```

