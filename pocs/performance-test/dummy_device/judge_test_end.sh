#!/bin/bash

if [ `docker ps | wc -l` -eq 1 ] ;then
    echo "done"
else
    echo "doing"
fi
