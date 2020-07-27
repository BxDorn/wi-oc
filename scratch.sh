clear
echo "Checking for presence of woc service file"

ls /etc/systemd/system/ | grep woc.service
serviceFile=($?)

if [[ $serviceFile -eq "0" ]]; then
    echo "service file present"
else
    echo "service not loaded, load now? (y/n)"
    read loadService
    if [[ $loadService != "y" ]]; then
        echo "no service loaded, exiting"
        exit
    else
        echo "loading service"
        cp ~/woc.service /etc/systemd/system/
        chmod +x /etc/systemd/system/woc.service
        sleep 2
    fi
fi

echo "serice file loaded, would you also like to enable the service? (y/n)"
read enableService
if [[ $enableService != "y" ]]; then
    "service not enabled, the woc will not survive a reboot of the unit."
    exit
else
    echo "enabling woc service"
    systemctl enable woc.service
    sleep 2
    echo "woc service enabled"
fi




firewall-cmd --direct --add-rule ipv4 filter INPUT 0 -m mac --mac-source 00:0c:29:3c:97:65 -j DROP


#-----------------------------------------------------------------------------------------
# Primary declaration and interface build
#-----------------------------------------------------------------------------------------
echo "Is this unit the primary WOC? (y/n)"
read primaryWoc



if [[ $primaryWoc == "y" ]]; then


else
    

fi


WOC 1 info

2600:6ce6:4400:65::7/64
2600:6ce6:4400:65::1
2600:6ce6:4403::1

WOC 2 info

2600:6ce6:4400:65::5/64
2600:6ce6:4400:65::1
2600:6ce6:4403::1





woc 2 info

2: ens192: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:06:d6:ff brd ff:ff:ff:ff:ff:ff
    inet 10.0.145.5/28 brd 10.0.145.15 scope global ens192
       valid_lft forever preferred_lft forever
    inet6 2600:6ce6:4400:65::5/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe06:d6ff/64 scope link 
       valid_lft forever preferred_lft forever
3: ens224: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:06:d6:09 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::20c:29ff:fe06:d609/64 scope link 
       valid_lft forever preferred_lft forever
4: ens256: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0c:29:06:d6:13 brd ff:ff:ff:ff:ff:ff
    inet 100.64.250.149/24 brd 100.64.250.255 scope global ens256:555
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe06:d613/64 scope link 
       valid_lft forever preferred_lft forever
5: ens256.2498@ens256: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 00:0c:29:06:d6:13 brd ff:ff:ff:ff:ff:ff
    inet 100.64.250.98/24 brd 100.64.250.255 scope global ens256.2498
       valid_lft forever preferred_lft forever
    inet 100.64.250.250/24 brd 100.64.250.255 scope global secondary dynamic ens256.2498
       valid_lft 218sec preferred_lft 218sec
    inet6 fe80::20c:29ff:fe06:d613/64 scope link 
       valid_lft forever preferred_lft forever



       WAG: 2600:6ce6:4403::1
       