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
startup_interval = float(os.environ.get('STARTUP_INTERVAL', 5))
data_type = os.environ.get('DATA_TYPE','string')

TOPIC_START = '/start'

cid = vmid + device_id
client = mqtt.Client(protocol=mqtt.MQTTv311, client_id=cid)


class DummyDevice(object):

    def __init__(self):
        self.message_num = msg_num
        self.seq = 0

    def send(self):
        
        topic = "/{}/{}/attrs".format(apikey, cid)
        if data_type == "string":
            data = "/{}/{}/{}/seq/{}".format(vmid, apikey, device_id, "%05d" % self.seq)
        elif data_type == "number":
            data = "{}".format( "%05d" % self.seq)
        else:
            print("Error data_type")
            return
        client.connect(host, port=port, keepalive=60)
        client.publish(topic, payload=json.dumps({"m": data}))
        client.disconnect()
        self.seq += 1
        self.message_num -= 1
        now = datetime.now().strftime("%S.%f")
        print(str(now) + device_id + " Send message succesfull.")
        

    def start(self):
        delay = random.randrange(0, send_interval, 1)
        time.sleep(delay)
        flag =0
        while True:
            now = float(datetime.now().strftime("%S.%f")) % send_interval
            time.sleep(0.4)
            if (send_interval / 2) >= now and flag == 0:
                self.send()
                flag = 1
            elif (send_interval / 2) <= now and flag == 1:
                flag = 0
            if self.message_num == 0:
                break


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

    print( device_id + "sleep " + str(startup_interval) + "s." )
    time.sleep(startup_interval)
    print("Start sending mqtt packets.")

    dummy_device = DummyDevice()
    dummy_device.start()
