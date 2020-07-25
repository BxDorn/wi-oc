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

