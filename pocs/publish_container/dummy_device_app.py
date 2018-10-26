from datetime import datetime
import json
import os
import random
import time

from paho.mqtt import client as mqtt

device_id = os.environ.get('DEVICE_ID')
vmid = os.environ.get('VM_ID')
host = os.environ.get('BROKER_HOST', 'localhost')
port = int(os.environ.get('BROKER_PORT', 1883))
username = os.environ.get('USERNAME')
password = os.environ.get('PASSWORD')
apikey = os.environ.get('APIKEY')
send_interval = int(os.environ.get('SEND_INTERVAL'))
msg_num = int(os.environ.get('MESSAGE_NUM', 100))

TOPIC_START = '/start'

cid = vmid + device_id
client = mqtt.Client(protocol=mqtt.MQTTv311, client_id=cid)


class DummyDevice(object):

    def start(self):
        dylay = 0
        message_num = msg_num
        seq = 0
        while(message_num > 0):
            now = int(datetime.now().strftime("%S")) % send_interval
            if now == 0:
                dylay = random.randrange(0, send_interval, 1)
            if now == dylay:
                topic = "/{}/{}/attrs".format(apikey, cid)
                data = {"vmid": vmid, "device_id": device_id, "seq": "%05d" % seq}
                client.connect(host, port=port, keepalive=60)
                client.publish(topic, payload=json.dumps(
                    {"m": "{}".format(json.dumps(data))}).replace('\\"',"\""))
                client.disconnect()
                message_num -= 1
                seq += 1
                print(str(now) + " Send message succesfull.")
            else:
                print(now)
            time.sleep(1)


def on_connect(client, userdata, flags, respons_code):
    if respons_code == 0:
        print("Connection succesfull")
        client.subscribe(TOPIC_START)


def on_message(client, userdata, msg):
    if msg.topic == TOPIC_START and msg.payload.decode('utf-8') == '1':
        print("Received Starting message.")
        client.disconnect()


if __name__ == '__main__':
    print("Start dummy device application.")
    client.on_connect = on_connect
    client.on_message = on_message
    client.username_pw_set(username, password)
    client.connect(host, port=port, keepalive=60)
    client.loop_forever()

    time.sleep(5)
    print("Start sending mqtt packets.")

    dummy_device = DummyDevice()
    dummy_device.start()
