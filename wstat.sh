#!/bin/bash

clear
echo "WOC Status"
echo ------------------------------------------------------
isPrimaryConfig=$(sed -n '2{p;q;}' /root/wi-oc/load_var.woc)
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
