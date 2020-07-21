#!/bin/bash


clear

ls | grep load_var.txt
firstTime=($?)

if [[ $firstTime -eq 1 ]]; then
    echo "It looks like this is the first running this script, press enter to continue"
    read enter
else
    echo "WARNING! - running this script after initial setup will overrite previously stored values"
    echo "To prevent this, 'ctrl-c' out now! - otherwise [Enter] to continue if you intend to reset the woc parameters"
    echo " -----------------------------------------------------------------------------"
    echo "do you want to continue?"
    read firstTimeAns
    if [[ $firstTimeAns != "y" ]]; then
        exit
    fi
fi

clear

echo "Welcome to the Wireless Offload Concentrator / Tunneling Router setup!"
echo "There are 2 numbered interfaces, and 2 unnumbered interfaces needed for the WOC to properly function."
echo "The standard setup is as follows:"
echo "ens192 - Dual stack interface and GREv6 source address of tunnel to the WAG for client traffic - this is the external interface"
echo "ens224 - Unnumbered interface that faces the internal LAN segments "
echo "ens256 - Failover cross connect 1 - bond0 member"
echo "ens161 - Failover cross connect 2 - bond0 member"
echo "bond0  - Failover interface"
echo " -----------------------------------------------------------------------------"
echo "Are the aforementioned interfaces present and linked appropriately? (y/n)"

read setupIntAns
if [ "$setupIntAns" == "y" ]
then
    rm -rf load_var.txt

    clear
    echo "Interface configuration accepted, here are your current interface parameters:"
    ip a
    echo "Is this interface configuration correct for your install?"
    read setupInt2Ans
        if [ "$setupInt2Ans" = "y" ]
        then
            echo "Please enter the WAG IPv6 endpoint address"
            read wagIpv6
            echo $wagIpv6 >> load_var.txt
        clear
        echo "The following parameters have been configured:"
        ipv6_wan=$(ip -6 addr show ens192 scope global | egrep -v dynamic | awk '$1 == "inet6" {print $2}' | awk '{print substr($1, 1, length($1)-3)}')
        echo "-------------------------------------------------------------------------"
        echo "The local IPv6 address for the dataplane tunnel is:"
        echo "$ipv6_wan"
        echo "-------------------------------------------------------------------------"
        echo "The WAG IPv6 endpoint is:"
        echo "$wagIpv6"
        echo "-------------------------------------------------------------------------"
        echo "is this unit the primary?"
        read isPrimary
        if [[ $isPrimary == "y" ]]; then
            echo "MACADDR=6a:55:c7:e2:f9:51" 
        else
            echo "MACADDR=6a:55:c7:e2:f9:52"
        fi


        echo "If at any time you need to change these variables re-run the setup script!"
        echo "the WOC will now reboot to apply the new settings"
        #reboot 10
        else
            echo "please correct any misconfigured interfaces / links and restart the setup script"
                exit
        fi

else
        echo "please correct any misconfigured interfaces / links and restart the setup script"
        exit
fi
exit