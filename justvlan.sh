#!/bin/bash

echo "The WOCs need 2 VLANs to monitor one another for the purposes of high-availability and failover, these 2 VLANs should be spanned to both the internal and failover interfaces (ens224, ens256)"
echo "you must provide one VLAN per WOC, when you setup the partner WOC you will provide the other VLAN"
echo "Please provide the VLAN ID number for this WOC (just the number)"
read vlanId

echo "VLAN $vlanid will be used for the failover network, please ensure it is spanned to all WOC internal (ens224) and failover (ens256) interfaces on both WOCs"

ens256file="ifcfg-ens256.$(vlanid)"
ens224file="ifcfg-ens224.$(vlanid)"




#cp ens256vlan.woc ifcfg-ens224."$vlanid"
#echo "VLAN_ID=" $vlanid >> "$ens256file"
#echo "VLAN_ID=" $vlanid >> "$ens256file"
#echo "DEVICE=ens256."$vlanid >> ifcfg-ens256."$vlanid"
#echo "DEVICE=ens224."$vlanid >> ifcfg-ens224."$vlanid"
#more ifcfg-ens256."$vlanid"
#more ifcfg-ens224."$vlanid"

ls