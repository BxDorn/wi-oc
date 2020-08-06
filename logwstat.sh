#!/bin/bash 
syslog=172.28.80.27 
port=5141 
/bin/bash /root/wi-oc/wstat.sh > status.log
logger -P 5141 -n 172.28.80.27 -f status.log
exit

