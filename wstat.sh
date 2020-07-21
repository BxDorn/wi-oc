#!/bin/bash


echo "WOC Status"
echo ------------------------------------------------------
isPrimaryConfig=$(sed -n '2{p;q;}' load_var.woc)

if [[ isPrimaryConfig != "Primary" ]]; then
	echo "Unit Configuration = Standby"
else
	echo "Init Configuration = Primary"
fi

opTag=$( tail -n 1 woc_status.woc )

echo "Unit Operational State =" $opTag

ip link show br0 | grep UP
ip link show BNG1 | grep UP
ip link show ens224 | grep UP


trackedMac=$(bridge fdb show | wc -l)
echo "total tracked MAC addresses = " $trackedMac
echo ------------------------------------------------------

exit
