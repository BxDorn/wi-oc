#!/bin/bash

#gather status
ip link show br0 | grep UP
br0Status=($?)
ip link show BNG1 | grep UP
bng1Status=($?)
ip link show ens224 | grep UP
224Statu=($?)

clear



echo "WOC Status"
echo ------------------------------------------------------
isPrimaryConfig=(sed -n '2{p;q;}' load_var.woc)

if [[ isPrimaryConfig != "Primary" ]]; then
	echo "Unit Configuration = Standby"
else
	echo "Init Configuration = Primary"
fi

isPrimary=(sed -n '3{p;q;}' load_var.woc)

if [[ $isPrimary == "Primary"  ]]; then
	echo "Unit Operational State = Primary"
else
	echo "Unit Operational State = Standby"
fi


trackedMac=(bridge fdb show | wc -l)
echo "total tracked MAC addresses = " $trackedMac
echo ------------------------------------------------------

exit
