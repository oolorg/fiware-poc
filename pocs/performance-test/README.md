# 負荷検証

構成例

![構成例](img/ConfigurationExample.jpg)

コンポーネント構成

![コンポーネント構成](img/ComponentComposition.jpg)

## 環境構築
### FIWAREサーバの構築

|項目|Version|
|:-:|:-:|
|OS|Ubuntu 16.04 LTS|
|docker|18.06.1-ce, build e68fc7a|
|docker-compose|1.22.0, build f46880fe|

#### Dockerのインストール

公式手順に従いインストールを行う
https://docs.docker.com/install/linux/docker-ce/ubuntu/

##### インストール手順

パッケージインデックスを更新

```
~$ sudo apt-get update
```

HTTPS経由でリポジトリを使用できるようにするためのパッケージをインストール

```
~$ sudo apt-get install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common
```

```
~$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```

Dockerの公式GPGキーを追加

```
~$ sudo apt-key fingerprint 0EBFCD88
```

フィンガープリント9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88の最後の8文字を検索して、フィンガープリントを持つキーが手元にあることを確認

```
~$ sudo add-apt-repository \
 "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
 $(lsb_release -cs) \
 stable"
```

パッケージインデックスを更新

```
~$ sudo apt-get update
```

リポジトリで利用可能なバージョンを一覧表示

```
~$ apt-cache madison docker-ce
```

特定バージョン(`docker-ce=18.06.1~ce~3-0~ubuntu`)のDockerをインストール

```
~$ sudo apt-get install docker-ce=18.06.1~ce~3-0~ubuntu
```

dockerグループを作成
　`groupadd: group 'docker' already exists`と表示されるが問題ない
 
```
~$ sudo groupadd docker
groupadd: group 'docker' already exists
```

自分のユーザーをdockerグループに追加

```
~$ sudo usermod -aG docker $USER
```

ログアウトし再ログイン後バージョンの確認

```
~$ docker --version
Docker version 18.06.1-ce, build e68fc7a
```

#### Docker Composeのインストール

公式手順に従いインストールを行う
https://docs.docker.com/compose/install/#install-compose

##### インストール手順

特定バージョン(1.22.0)のDocker Composeをダウンロード

```
~$ sudo curl -L "https://github.com/docker/compose/releases/download/1.22.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

実行可能権限をバイナリに適用

```
~$ sudo chmod +x /usr/local/bin/docker-compose
```

/usr/binパスにシンボリックリンクの作成

```
~$ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

バージョンの確認

```
~$ docker-compose --version
docker-compose version 1.22.0, build f46880fe
```

#### 検証を実施するために必要なパッケージのインストール

- sysstat　(shell/logging/host_metrics.shでシステムの状態(CPU,メモリ,ディスクI/Oなど)監視のために使用)
- jq　(shell/cleanup/calc.shでスループットを取得するシェルの中でJSONから値を抽出するために使用)
- mosquitto-clients　(shell/init/start_init.shでMQTTメッセージ送信のために使用)

```
~$ sudo apt install sysstat jq mosquitto-clients
```

#### gitのクローン

```
~$ git clone https://github.com/oolorg/fiware-poc.git
```

### 負荷サーバの構築

|項目|Version|
|:-:|:-:|
|OS|Ubuntu 16.04 LTS|
|docker|18.06.1-ce, build e68fc7a|

#### Dockerのインストール

[[FIWAREサーバの構築]の[dockerのインストール]](#dockerのインストール)手順に従いdockerのインスールを行う

#### 負荷をかけるために必要なパッケージのインストール

- sysstat　(shell/logging/host_metrics.shでシステムの状態(CPU,メモリ,ディスクI/Oなど)監視のために使用)
- jq　(shell/cleanup/calc.shでスループットを取得するシェルの中でJSONから値を抽出するために使用)
- bc　(dummy_device/run-containers.shで複雑な計算実施のために使用)

```
~$ sudo apt install sysstat jq bc
```

#### gitのクローン

```
~$ git clone https://github.com/oolorg/fiware-poc.git
```

#### 疑似デバイス用コンテナイメージのビルド

```
~$ cd fiware-poc/pocs/performance-test/dummy_device
~/fiware-poc/pocs/performance-test/dummy_device$ docker build . -t dummy_device
```

---

## 負荷試験実施手順

負荷試験実施シーケンス

![負荷試験実施シーケンス](img/PerformanceTestSequence.jpg)

### 1.事前準備

#### 負荷実施シェルの編集　【FIWAREサーバ】

`fiware-poc/pocs/performance-test/shell/init/start_init.sh`の

`export TEST_HOME=`にfiware-pocディレクトリの絶対パスを記載する。

記載例

```
export TEST_HOME=/home/user098/fiware-poc
```

#### Docker Composeファイルの決定　【作業対象なし】

検証したい内容により以下2ファイルのどちらかを使用するか決定する。

- Cygnusの集計情報が有効な場合
`docker-compose_aggregate-on.yml`

- Cygnusの集計情報が無効な場合
`docker-compose_aggregate-off.yml` 

#### 負荷のシナリオの決定　【作業対象なし】

擬似デバイスコンテナ起動シェルの実行に必要な項目を決定する

負荷のシナリオのイメージ
![負荷のシナリオ](img/PerformanceScenario.jpg)

|項目|説明|算出方法|例|
|:-:|:-:|:-:|:-:|
|**デバイス数**|起動するデバイスの台数|決めた値|100|
|**データ送信間隔**|1デバイスあたりのデータの送信間隔(秒)|決めた値|1秒|
|**データ送信回数**|1デバイスあたりのデータ送信回数|(デバイス起動時間＋測定時間＋ランニング時間×2＋デバイス停止時間)/データ送信間隔|87400回|
|**デバイス起動合計時間**|全てのデバイスが起動するのにかける時間(秒)|デバイス数×デバイス起動間隔|400秒|
|**送信データタイプ**|送信データの内容([string] or [number])|決めた値|string|
|デバイス起動間隔|1デバイスあたりの起動間隔(秒)|決めた値|4秒|
|ランニング時間|負荷が定常状態にするためのランニング時間(秒)|決めた値|300秒|
|測定時間|試験データの対象とする測定時間(秒)|決めた値|86400秒|

#### subscriptionファイルの決定　【作業対象なし】

検証したい内容により以下2ファイルのどちらかを使用するか決定する。

- Cometに全ての属性値(messagesとTimeInstant)を蓄積する場合
`messages-timeinstant`

- Cometに特定の属性値(messages)のみ蓄積する場合
`messages` 


### 2.Docker Composeの起動　【FIWAREサーバ】

事前準備で決定した項目に従い、下記コマンドでFIWAREサーバを起動する

```
$ cd fiware-poc/pocs/performance-test/platformedit
$ docker-compose -f {Docker Compose ファイル名} up -d
```

各コンポーネントの起動確認を実施し、起動していないコンポーネントがある場合は再度`docker-compose -f {Docker Compose ファイル名} up -d`コマンドを実行し、その後起動確認を行う

```
~$ docker-compose -f {Docker Compose ファイル名} ps
```

起動していないコンポーネントがある場合のみ実施

```
~$ docker-compose -f {Docker Compose ファイル名} up -d
```

各コンポーネントの起動確認を実施

```
~$ docker-compose -f {Docker Compose ファイル名} ps
```

### 3.擬似デバイスコンテナ起動シェルの実行　【負荷サーバ】

事前準備で決定した項目に従い、下記コマンドで擬似デバイスコンテナ起動シェルを実行する

```
~$ cd fiware-poc/pocs/performance-test/dummy_device
$ ./run-containers.sh {FIWAREサーバIP} {デバイス数} {データ送信間隔(秒)} {データ送信回数} {デバイス起動合計時間(秒)} {送信データタイプ}
```

### 4.試験開始シェルの実行　【FIWAREサーバ】

事前準備で決定した項目に従い、下記コマンドで試験開始シェルを実行する

```
~$ cd fiware-poc/pocs/performance-test/shell/init
$ ./start_init.sh {デバイス数} {subscriptionファイル名}
```

### 5.試験後のログ取得シェルの実行　【FIWAREサーバ】

事前準備で決定した項目に従い、下記コマンドで試験後のログ取得シェルを実行する

```
~$ cd fiware-poc/pocs/performance-test/shell/cleanup
$ ./cleanup.sh {デバイス数}
```

### 6.Docker Composeの停止　【FIWAREサーバ】

事前準備で決定した項目に従い、下記コマンドでFIWAREサーバを停止する

```
~$ cd fiware-poc/pocs/performance-test/platformedit
$ docker-compose -f {Docker Compose ファイル名} down
```

### 7.擬似デバイスコンテナの削除シェルの実行　【負荷サーバ】

下記コマンドで、試験後のログ取得シェルを実行する

```
~$ cd fiware-poc/pocs/performance-test/dummy_device
$ ./del_containers.sh
```
