#!/bin/bash 
syslog=172.28.80.27 
port=5141 
./root/wi-oc/wstatus.woc
logger -P 5141 -n 172.28.80.27 -f status.log
