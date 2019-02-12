FROM python:3.6-alpine

COPY dummy_device_app.py /home/dummy_device_app.py

RUN pip install paho-mqtt

CMD ["python", "-u", "/home/dummy_device_app.py"]
