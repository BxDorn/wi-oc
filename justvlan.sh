#!/bin/bash

echo "The WOCs need 2 VLANs to monitor one another for the purposes of high-availability and failover, these 2 VLANs should be spanned to both the internal and failover interfaces (ens224, ens256)"
echo "you must provide one VLAN per WOC, when you setup the partner WOC you will provide the other VLAN"
echo "Please provide the VLAN ID number for this WOC (just the number)"
read vlanID

echo "VLAN" $vlanID "will be used for the failover network, please ensure it is spanned to all WOC internal (ens224) and failover (ens256) interfaces on both WOCs"

#-----------------------------------------------------------------------------------------
# build ens256
#-----------------------------------------------------------------------------------------
cp ens256.woc ifcfg-ens256.$vlanID
echo VLAN_ID=$vlanID >> $ens256file
echo DEVICE=ens256.$vlanID >> ifcfg-ens256.$vlanID
more ifcfg-ens256.$vlanID
ls
