#!/bin/bash

clear

#-----------------------------------------------------------------------------------------
# User intent declaration
#-----------------------------------------------------------------------------------------
echo "This program will guide you through the interface setup for your Wireless Offload Concentrator"
echo "This operation will over-write all current WOC interfaces, it should only be run to install the WOC"
echo " or to correct any errors entered during a previous run of this script."

echo "do you want to proceed? (y/n)"

read proceed

if [[ $proceed != "y" ]]; then
	echo "setup canceled."
	exit
fi

clear

#-----------------------------------------------------------------------------------------
# User readme
#-----------------------------------------------------------------------------------------
echo "There are 2 primary interfaces associated with the WOC, the internal (ens224) interface"
echo "and the external (ens192) interface."
echo "The internal interface is an unnumbered ethernet interface that connects to the local LAN"
echo "every VLAN spanned to this interface from the connected switch will be forwarded to the WAG."
echo "It is therefore necessary for you to control the trunk interface on the switch to prevent" 
echo "unwanted traffic"
echo "from traversing the WOC."
echo "For example, on a Cisco switch the configuration would include the following:"
echo "---------------------------------------------"
echo "switchport mode trunk"
echo "switchport trunk allowed vlan 20,40,666"
echo "---------------------------------------------"
echo "This will ensure that only vlans 20, 40, and 666 have access to the WOC tunneling transport to the WAG." 
echo "you can of course add VLANs later as you see fit"
echo "by simply adding the vlan to the trunk interface on the switch."
echo "Press any key to continue..."
read anykey

echo "The external interface can be dual-stacked with IPv4 and IPv6 addressing, but for the purposes of tunneling,"
echo "only requires an IPv6 address.The IPv4 address given to this interface is used for the purposes of management"
echo "and reporting, and is optoinal - though highly recommended."



#-----------------------------------------------------------------------------------------
# Collect external interface parameters, build dataplane interfaces
#-----------------------------------------------------------------------------------------
echo "Now lets begin to enter some informaion about the WOC"
echo "First, lets configure the external interface"

echo "please enter the IPv6 address you would like to assign to the external interface"
read localIPv6

echo $localIPv6 "will be used as the external interface IPv6 address - if this is correct, press" 
echo "Enter to proceed, otherwise ctrl-c and start the script again."
read enter
echo "Please enter the IPv6 default gateway:"
read localIPv6Gateway

clear

echo "The following parameters will be applied to the external interface (ens192):"
echo "---------------------------------------------"
echo "ens192"
echo "IPv6 address "$localIPv6
echo "IPv6 gateway: "$localIPv6Gateway
echo "---------------------------------------------"

echo "Are these parameters correct?? (y/n)"
read applyExtYn

if [[ $applyExtYn != "y" ]]; then
	echo "Parameters discarded, please re-run the script"
	exit
else

#-----------------------------------------------------------------------------------------
# rebuild local files and apply
#-----------------------------------------------------------------------------------------
	echo "Writing interface parameters"
	echo "IPV6ADDR="$localIPv6 >> /etc/sysconfig/network-scripts/ifcfg-ens192
	echo "IPV6_DEFAULTGW="$localIPv6Gateway >> /etc/sysconfig/network-scripts/ifcfg-ens192
	clear
	more ifcfg-ens192
fi

#-----------------------------------------------------------------------------------------
# Collect failover interface parameters
#-----------------------------------------------------------------------------------------
echo "The WOCs need 2 VLANs to monitor one another for the purposes of high-availability and failover,"
echo "these 2 VLANs should be spanned to both the internal and failover interfaces (ens224, ens256)"
echo "you must provide one VLAN per WOC, when you setup the partner WOC you will provide the other VLAN"
echo "Please provide the VLAN ID number for this WOC (just the number)"
read vlanID
echo "VLAN" $vlanID "will be used for the failover network, please ensure it is spanned to all WOC internal"
echo "(ens224) and failover (ens256) interfaces on both WOCs"

#-----------------------------------------------------------------------------------------
# build ens256
#-----------------------------------------------------------------------------------------
rm -rf ifcfg-ens256
cp ens256.woc ifcfg-ens256
echo DEVICE=ens256 >> ifcfg-ens256
cp ifcfg-ens256 /etc/sysconfig/network-scripts/
echo "---------------------------------------------"
echo "Internal interface (ens256) built"
echo "---------------------------------------------"
more ifcfg-ens256
sleep 3

#-----------------------------------------------------------------------------------------
# build ens256.VLAN
#-----------------------------------------------------------------------------------------
rm -rf ifcfg-ens256.$vlanID
cp ens256.woc ifcfg-ens256.$vlanID
echo VLAN_ID=$vlanID >> ifcfg-ens256.$vlanID
echo DEVICE=ens256.$vlanID >> ifcfg-ens256.$vlanID
cp ifcfg-ens256.$vlanID /etc/sysconfig/network-scripts/
echo "---------------------------------------------"
echo "Heartbeat Interface built"
echo "---------------------------------------------"
more ifcfg-ens256.$vlanID
sleep 3

#-----------------------------------------------------------------------------------------
# build ens224
#-----------------------------------------------------------------------------------------
rm -rf ifcfg-ens224
cp ens224.woc /etc/sysconfig/network-scripts/ifcfg-ens224
echo "---------------------------------------------"
echo "Internal Interface built"
echo "---------------------------------------------"
more /etc/sysconfig/network-scripts/ifcfg-ens224
sleep 3

#-----------------------------------------------------------------------------------------
# build ens224.VLAN
#-----------------------------------------------------------------------------------------
cp ens224.woc ifcfg-ens224.$vlanID
echo VLAN_ID=$vlanID >> ifcfg-ens224.$vlanID
echo DEVICE=ens256.$vlanID >> ifcfg-ens224.$vlanID
cp ifcfg-ens224.$vlanID /etc/sysconfig/network-scripts/ifcfg-ens224.$vlanID
echo "---------------------------------------------"
echo "Internal Failover Interface built"
echo "---------------------------------------------"
more ifcfg-ens224.$vlanID

systemctl restart network.service
	sleep 7 &
	PID=$!
	i=1
	sp="/-\|"
	echo -n ' '
	while [ -d /proc/$PID ]
	do
	  printf "\b${sp:i++%${#sp}:1}"
	done

#-----------------------------------------------------------------------------------------
# end
#-----------------------------------------------------------------------------------------
echo "---------------------------------------------"
echo "All done! Please run woc_setup.sh to configure your Wi-Fi Offload Concentrator"
exit









