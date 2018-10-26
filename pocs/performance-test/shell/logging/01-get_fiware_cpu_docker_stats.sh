#!/bin/bash

while :
do
    date >> fiware-cpu.log;docker stats --no-stream >> fiware-cpu.log;echo "" >> fiware-cpu.log
done

