# OOL FIWARE Sensortag Poc

沖縄オープンラボラトリで検証しているFIWAREとSensor Tagのリポジトリです。

このアプリケーションはRaspberry Pi 3 Model B上で動作し、Sensor Tagから取得したセンサーデータをFIWAREへアップロードします。

## Install

必須パッケージのインストールをインストールします。

```bash
$ sudo apt install python3-pip libglib2.0-dev
```

```bash
$ git clone https://github.com/oolorg/ool-fiware-sensortag && cd ool-fiware-sensortag
$ pip3 install -r requirementes.txt
```

## Usage

以下のスクリプトを実行します。

```bash
$ ./main.py
```
