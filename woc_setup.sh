#!/bin/bash


clear

ls ~/ | grep load_var
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
echo "ens256 - Failover cross connect 1 - must be connected to the partner WOC. - heartbeat send"
echo "ens161 - Failover cross connect 2 - must be connected to the partner WOC. - heartbeat receive"
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

        echo "If at any time you need to change these variables re-run the setup script!"
        echo "the WOC will now reboot to apply the new settings"
        #reboot 10
        exit
        else
            echo "please correct any misconfigured interfaces / links and restart the setup script"
                exit
        fi

else
        echo "please correct any misconfigured interfaces / links and restart the setup script"
        exit
fi
clear
echo "Checking status of woc service"

ls /etc/systemd/system/ | grep woc.service
serviceFile=($?)
if [[ serviceFile -eq 0 ]]; then
    echo "service loaded............"
    systemctl status woc.service
    echo "checking status of woc service....."
    sleep 1
    systemctl status woc.service | grep enabled
    serviceEnabled=($?)
    if [[ serviceEnabled -eq 0 ]]; then
        echo "the woc service is enabled....."
        exit
    fi
else
    echo "service not loaded, load now? (y/n)"
    read loadService
    if [[ loadService != "y" ]]; then
        echo "no service loaded, exiting"
        exit
    else
        echo "loading service"
        cp ~/woc.service /etc/systemd/system/
        chmod +x /etc/systemd/system/woc.service
        sleep 2
        echo "serice loaded, would you also like to enable the service? (y/n)"
        read enableService
        if [[ enableService != "y" ]]; then
            "service not enabled, the woc will not survive a reboot of the unit."
            exit
        else
            echo "enabling woc service"
            systemctl enable woc.service
            sleep 2
            echo "woc service enabled"
        fi
    fi
fi
exit