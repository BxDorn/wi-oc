#!/bin/bash

clear
echo "WOC Status"
echo ------------------------------------------------------
isPrimaryConfig=$(sed -n '1{p;q;}' /root/wi-oc/woc_status.woc)
echo "unit configured as" $isPrimaryConfig
opTag=$( tail -n 1 woc_status.woc )
echo "Unit Operational State =" $opTag
echo ------------------------------------------------------
ip link show
echo ------------------------------------------------------
trackedMac=$(bridge fdb show | wc -l)
echo "total tracked MAC addresses = " $trackedMac
echo ------------------------------------------------------

exit
