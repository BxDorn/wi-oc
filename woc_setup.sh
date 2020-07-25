#!/bin/bash


clear

#grab interface mac addresses
#ens256Mac=$(ip -o link | awk '$2 == "ens256:" {print $(NF-2)}')





ls | grep load_var.woc
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
echo "ens192 - External Interface - Dual stack interface and GREv6 source address of tunnel to the WAG for client traffic - this is the external interface"
echo "ens224 - Internal Interface - Unnumbered interface that faces the internal LAN segments "
echo "ens256 - Failover Test Interface"
echo " -----------------------------------------------------------------------------"
echo "Are the aforementioned interfaces present and linked appropriately? (y/n)"

read setupIntAns
if [ "$setupIntAns" == "y" ]
then
    rm -rf load_var.woc
#    rm -rf /etc/sysconfig/network-scripts/ifcfg-ens192
#    rm -rf /etc/sysconfig/network-scripts/ifcfg-ens224




    echo "is this unit the primary?"
        read isPrimary
            if [[ $isPrimary == "y" ]]; then
                #copy ifcfg-files for primary
            else
 
            fi
    echo "interface configuration complete, Press Enter to continue..."



    #echo "The folloing bond0 parameters will be used, Press Enter to continue"
    #more ifcfg-bond0
    
    read pressEnter
    clear
    echo "Interface configuration accepted, here are your current interface parameters:"
    ip a
    echo "Is this interface configuration correct for your install?"
    read setupInt2Ans
        if [ "$setupInt2Ans" = "y" ]
        then
            echo "Please enter the WAG IPv6 endpoint address"
            echo "the ipv6 WAG address cannot be abbreviated with :: to hide zeros - enter the full address"
            read wagIpv6
            echo $wagIpv6 >> load_var.woc
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
        cp ifcfg-bond0 /etc/sysconfig/network-scripts/
        echo "Primary" >> load_var.woc

        clear
        echo "Checking for presence of woc service file"

        ls /etc/systemd/system/ | grep woc.service
        serviceFile=($?)

        if [[ $serviceFile -eq "0" ]]; then
            echo "service file present"
        else
            echo "service file not round, load now? (y/n)"
            read loadService
            if [[ $loadService != "y" ]]; then
                echo "no service loaded, exiting"
                exit
            else
                echo "loading service"
                cp woc.service /etc/systemd/system/
                chmod +x /etc/systemd/system/woc.service
                cpStatus=($?)
                if [[ $cpStatus -eq 0 ]]; then
                    echo "serice file loaded!"
                fi
            fi
        fi

        echo "Would you like to enable the service? (y/n)"
        read enableService
        if [[ $enableService != "y" ]]; then
            "service not enabled, the woc will not survive a reboot of the unit."
            exit
        else
            echo "enabling woc service"
            systemctl enable woc.service
            sleep 2
            echo "woc service enabled"
            
            firewall-cmd --permanent --zone=trusted --add-source=$wagIpv6
            firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -p gre -j ACCEPT
            firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -p icmpv6 -s $wagIpv6 -j ACCEPT
            #sleep 2
            echo "restarting firewall"
            #systemctl stop firewalld.service
            #systemctl disable firewalld.service

        fi
        echo "If at any time you need to change these variables re-run the setup script!"
        echo "Press Enter to reboot to apply the new settings"
        read pressEnter
        reboot
        else
            echo "please correct any misconfigured interfaces / links and restart the setup script"
                exit
        fi

else
        echo "please correct any misconfigured interfaces / links and restart the setup script"
        exit

fi
exit