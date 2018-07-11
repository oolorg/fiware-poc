# オープンデータとFIWAREの検証メモ

# 目次

* [構築](#構築)
* [動作確認](#動作確認)
* [実際に沖縄のオープンデータを使用する](#実際に沖縄のオープンデータを使用する)
* [運用](#運用)

## 構築

構築はdocker-compose.ymlを使用する。

```bash
$ git clone https://github.com/oolorg/fiware-poc.git && cd fiware-poc/pocs/dynamic-data-poc/ckan-demo/
```

コンテナを起動する。

```bash
$ docker-compose up -d
Creating network "ckandemo_default" with the default driver
Creating redis-demo    ... done
Creating mongodb-demo  ... done
Creating postgres-demo ... done
Creating solr-demo     ... done
Creating ckan-demo     ... done
Creating orion-demo    ... done
Creating cygnus-demo   ... done
```

## CKANユーザーの作成

CygnusがCKANにデータを登録するために書き込み権限を持ったユーザーを作成する必要がある。
ここでは、管理者権限を持ったadminユーザーを作成する。

```bash
$ docker exec -it ckan /usr/local/bin/ckan-paster --plugin=ckan sysadmin -c /etc/ckan/production.ini add admin
```

API Keyが発行されるのでメモしておく。

## Cygnusの設定

Cygnusの設定ファイルにCKANのadminユーザーのAPI Keyを登録する必要がある。

docker-compose.ymlのCYGNUS_CKAN_API_KEY環境変数として登録する。
編集後、Cygnusのコンテナを再起動(削除+起動)する。

```bash
$ vim docker-compose.yml
```

```yaml
  cygnus-demo:
    container_name: cygnus-demo
    image: fiware/cygnus-ngsi:1.7.1
    links:
      - ckan-demo
    ports:
      - "5050:5050"
      - "8081:8081"
    environment:
      - CYGNUS_LOG_LEVEL=DEBUG
      - CYGNUS_CKAN_HOST=ckan-demo
      - CYGNUS_CKAN_PORT=5000
      - CYGNUS_CKAN_API_KEY=8501b681-4b92-4cb1-b4f7-e7ed88f101ee
      - CYGNUS_CKAN_ATTR_PERSISTENCE=row
```

cygnus-demoコンテナを再起動する。

```bash
$ docker-compose up -d
```

# 実際に沖縄のオープンデータを使用する

## 使用するオープンデータ

沖縄県が公開している市町村ごとの面積データを登録する。
オープンデータの[沖縄県のHP](http://www.pref.okinawa.jp/site/kikaku/joho/kikaku/opendata/category_stat.html)で配布されている。まずは、この面積データのうち那覇市、宜野湾市、石垣市の3市町村のデータを登録する。

### データの登録

#### Organizationの作成

リクエスト

```bash
$ curl -X POST "http://localhost:5000/api/3/action/organization_create" -d '{"name":"okinawa_pref"}' -H  "Authorization: 8501b681-4b92-4cb1-b4f7-e7ed88f101ee"
```

レスポンス

```json
{"help": "http://localhost:80/api/3/action/help_show?name=organization_create", "success": true, "result": {"users": [{"email_hash": "5b37040e6200edb3c7f409e994076872", "about": null, "capacity": "admin", "name": "admin", "created": "2018-06-05T05:50:26.211997", "sysadmin": true, "activity_streams_email_notifications": false, "state": "active", "number_of_edits": 45, "display_name": "admin", "fullname": null, "id": "e9e10a13-6431-4b33-b9e1-df42606098a7", "number_created_packages": 7}], "display_name": "okinawa_pref", "description": "", "image_display_url": "", "package_count": 0, "created": "2018-06-22T02:23:20.162800", "name": "okinawa_pref", "is_organization": true, "state": "active", "extras": [], "image_url": "", "groups": [], "type": "organization", "title": "", "revision_id": "f5db8856-f15f-4e79-ab77-bc6249340907", "num_followers": 0, "id": "1d813a32-5d1d-494a-9a88-7701d36d5b4e", "tags": [], "approval_status": "approved"}}
```

#### パッケージの作成

パッケージ(データセット)を作成するときに、nameは以下のように指定する。

[Fiware-Service]_[Fiware-ServicePath]

リクエスト

```bash
$ curl -X POST  "http://localhost:5000/api/3/action/package_create" -d '{"name":"okinawa_pref_area","owner_org":"okinawa_pref"}' -H  "Authorization: 8501b681-4b92-4cb1-b4f7-e7ed88f101ee"
```

レスポンス

```json
{"help": "http://localhost:80/api/3/action/help_show?name=package_create", "success": true, "result": {"license_title": null, "maintainer": null, "relationships_as_object": [], "private": false, "maintainer_email": null, "num_tags": 0, "id": "fe3eae81-2d33-42b5-9bab-ea77dcb4a5af", "metadata_created": "2018-06-22T02:25:34.503082", "metadata_modified": "2018-06-22T02:25:34.503095", "author": null, "author_email": null, "state": "active", "version": null, "creator_user_id": "e9e10a13-6431-4b33-b9e1-df42606098a7", "type": "dataset", "resources": [], "num_resources": 0, "tags": [], "groups": [], "license_id": null, "relationships_as_subject": [], "organization": {"description": "", "created": "2018-06-22T02:23:20.162800", "title": "", "name": "okinawa_pref", "is_organization": true, "state": "active", "image_url": "", "revision_id": "f5db8856-f15f-4e79-ab77-bc6249340907", "type": "organization", "id": "1d813a32-5d1d-494a-9a88-7701d36d5b4e", "approval_status": "approved"}, "name": "area", "isopen": false, "url": null, "notes": null, "owner_org": "1d813a32-5d1d-494a-9a88-7701d36d5b4e", "extras": [], "title": "area", "revision_id": "71555a8e-8aef-4d69-9266-bb991f47c101"}}
```

リソースを作成するときにURLを指定できる。ここにCKAN APIを指定してあげればCKAN Viewで表示できるかも？

#### リソースの作成

リクエスト

```bash
$ curl -X POST  "http://localhost:5000/api/3/action/resource_create" -d '{"name":"沖縄県_面積","url":"none","format":"","package_id":"okinawa_pref_area"}' -H  "Authorization: 8501b681-4b92-4cb1-b4f7-e7ed88f101ee"
```

レスポンス

```json
{"help": "http://localhost:80/api/3/action/help_show?name=resource_create", "success": true, "result": {"cache_last_updated": null, "cache_url": null, "mimetype_inner": null, "hash": "", "description": "", "format": "", "url": "http://none", "created": "2018-06-22T02:26:20.792366", "state": "active", "package_id": "fe3eae81-2d33-42b5-9bab-ea77dcb4a5af", "last_modified": null, "mimetype": null, "url_type": null, "position": 0, "revision_id": "951b907b-d307-4d61-a44b-4deaa3e99136", "size": null, "datastore_active": false, "id": "1545a7be-2714-4d1e-b7db-d3f198b8192e", "resource_type": null, "name": "\u6c96\u7e04\u770c_\u9762\u7a4d"}}
```

フィールドを定義したJSONファイルを定義する。

```json:fields.json
{
  "fields": [
    {"id":"recvTime","type":"text"},
    {"id":"fiwareServicePath","type":"text"},
    {"id":"entityId","type":"text"},
    {"id":"entityType","type":"text"},
    {"id":"市町村","type":"text"},
    {"id":"面積","type":"text"}
  ],
  "resource_id":"1545a7be-2714-4d1e-b7db-d3f198b8192e",
  "force":"true"
}
```

#### データストアの作成

```bash
$ curl -X POST "http://localhost:5000/api/3/action/datastore_create" -H  "Authorization: 8501b681-4b92-4cb1-b4f7-e7ed88f101ee" -d @fields.json
```

リソースIDが見つからなかった場合以下のエラーが返る。
リソースIDはnameではなくIDを指定しなければならない。

```json
{"help": "http://localhost:80/api/3/action/help_show?name=datastore_create", "success": false, "error": {"resource_id": ["Not found: Resource"], "__type": "Validation Error"}}
```

正常なレスポンスは以下

```json
{"help": "http://localhost:80/api/3/action/help_show?name=datastore_create", "success": true, "result": {"fields": [{"type": "text", "id": "recvTime"}, {"type": "text", "id": "fiwareServicePath"}, {"type": "text", "id": "entityId"}, {"type": "text", "id": "entityType"}, {"type": "text", "id": "\u5e02\u753a\u6751"}, {"type": "text", "id": "\u9762\u7a4d"}], "method": "insert", "resource_id": "1545a7be-2714-4d1e-b7db-d3f198b8192e"}}
```

## データを登録してCKANに通知する

```bash
$ curl localhost:1026/v1/updateContext -sS -H 'Fiware-Service: 沖縄県' -H 'Fiware-ServicePath: /面積' -H 'Content-Type: application/json' -H 'Accept: application/json' -d @01_menseki.json
{"orionError":{"code":"400","reasonPhrase":"Bad Request","details":"a component of ServicePath contains an illegal character"}}
```

CKANにデータを登録することを考慮すると、Fiware-ServiceヘッダーがCKANのOrganizationに、Fiware-ServicePathがCKANのDataset/Resourceに相当するため、上記のようにしたいところだが、OrionのAPIはヘッダーに日本語(Multi Byte文字)を受け付けない。
本来は、日本語に対応すべきだがここでは回避策としてローマ字を使用する。

```bash
$ curl localhost:1026/v1/updateContext -sS -H 'Fiware-Service: okinawa-pref' -H 'Fiware-ServicePath: /area' -H 'Content-Type: application/json' -H 'Accept: application/json' -d @01_menseki.json
```

#### サブスクリプションの登録

オープンデータが登録されると同時にCygnusに通知するためにサブスクリプションを登録する。

```bash
$ curl localhost:1026/v1/subscribeContext -sS -H 'Fiware-Service: okinawa_pref' -H 'Fiware-ServicePath: /area' -H 'Content-Type: application/json' -H 'Accept: application/json' -d @01_menseki_sub.json
```

レスポンス

```json
{"subscribeResponse":{"subscriptionId":"5b2c5d0a580b6d93c86a0ac5","duration":"P1M","throttling":"PT5S"}
```

#### エンティティの登録

リクエスト

```bash
$ curl localhost:1026/v1/updateContext -sS -H 'Fiware-Service: okinawa_pref' -H 'Fiware-ServicePath: /area' -H 'Content-Type: application/json' -H 'Accept: application/json' -d @01_menseki.json
```

レスポンス

```json
{"contextResponses":[{"contextElement":{"type":"面積","isPattern":"false","id":"沖縄県","attributes":[{"name":"那覇市","type":"float","value":""},{"name":"宜野湾市","type":"float","value":""},{"name":"石垣市","type":"float","value":""}]},"statusCode":{"code":"200","reasonPhrase":"OK"}}]}
```

日本語の文字列はCygnusによってUnicodeに変換されてCKANに転送される。
e.g. 「面積」→「\u9762\u7a4d」

### CKAN APIからのデータの取得

```bash
$ curl -sS http://localhost:5000/api/3/action/datastore_search -d '{"resource_id":"9500cc7b-67ea-4ef3-88a2-d8a0a265c46c","filters":{"attrName":"石垣市"}}' | python -m json.tool
{
    "help": "http://localhost:80/api/3/action/help_show?name=datastore_search",
    "result": {
        "_links": {
            "next": "/api/3/action/datastore_search?offset=100",
            "start": "/api/3/action/datastore_search"
        },
        "fields": [
            {
                "id": "_id",
                "type": "int"
            },
            {
                "id": "recvTimeTs",
                "type": "int4"
            },
            {
                "id": "recvTime",
                "type": "timestamp"
            },
            {
                "id": "fiwareServicePath",
                "type": "text"
            },
            {
                "id": "entityId",
                "type": "text"
            },
            {
                "id": "entityType",
                "type": "text"
            },
            {
                "id": "attrName",
                "type": "text"
            },
            {
                "id": "attrType",
                "type": "text"
            },
            {
                "id": "attrValue",
                "type": "json"
            },
            {
                "id": "attrMd",
                "type": "json"
            }
        ],
        "filters": {
            "attrName": "\u77f3\u57a3\u5e02"
        },
        "include_total": true,
        "records": [
            {
                "_id": 3,
                "attrMd": null,
                "attrName": "\u77f3\u57a3\u5e02",
                "attrType": "float",
                "attrValue": "229",
                "entityId": "\u6c96\u7e04\u770c",
                "entityType": "\u9762\u7a4d",
                "fiwareServicePath": "/area",
                "recvTime": "2018-06-22T02:31:09",
                "recvTimeTs": 1529634669
            }
        ],
        "records_format": "objects",
        "resource_id": "9500cc7b-67ea-4ef3-88a2-d8a0a265c46c",
        "total": 1
    },
    "success": true
}
```


# 運用

## オープンデータ提供者

1. 登録するオープンデータのNGSIフォーマットを検討する

2. オープンデータのフォーマット(データによって異なる)をNGSIフォーマットに書き換える

3. 定義したNGSIフォーマットをCKANに登録する(datastoreリソースを作成する)

4. Orionにサブスクリプションを登録する

5. Orionにオープンデータを登録する

## オープンデータ利用者

1. CKAN上でオープンデータおよびオープンデータのAPIを検索する

2. オープンデータのAPIを利用する

