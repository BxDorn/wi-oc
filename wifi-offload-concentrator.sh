#!/bin/bash


#Declarations
log=/root/wi-oc/log_woc.txt
now=$(date)
i=0
j=0
#echo "Standby" > /root/wi-oc/woc_status.woc

vlanID=$(sed '2q;d' load_var.woc)





ls /root/wi-oc/ | grep load_var.woc
loadVarPresent=($?)
if [[ $loadVarPresent -eq 1 ]]; then
  echo $(date) "no GRE endpoint configured, please run setup!"
  exit
fi


#pull the IPv6 address from the 
ipv6_wan=$(ip -6 addr show ens192 scope global | egrep -v dynamic | awk '$1 == "inet6" {print $2}' | awk '{print substr($1, 1, length($1)-3)}')

#pull wag endpoint from load_var.woc in local dir.
wagEndpt=$(sed -n '1{p;q;}' /root/wi-oc/load_var.woc)

# pre-build bridge function, disable bridge.
set -x

# create the gre tap and bridge interface:
#  ip link add BNG1 type ip6gretap remote 2600:6ce6:4403::1 local $ipv6_wan
  ip link add BNG1 type ip6gretap remote $wagEndpt local $ipv6_wan
  ip link add name br0 type bridge

# add gretap and ethernet interface (inside) to bridge (br0)
  ip link set BNG1 master br0
       
# Enable links
  ip link set BNG1 up
  ip link set ens224 up
  ip link set ens192 up

# disable the bridge
  ip link set br0 down

# bridge link set dev ens224 guard on
set +x

#moved to setup file - deprecated here
#firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -p gre -j ACCEPT
#firewall-cmd --permanent --direct --add-rule ipv6 filter INPUT 0 -p icmpv6 -s $wagEndpt -j ACCEPT



## establish counter for HA retries - after 5 attempts the script will trigger a failover.
while [ $i -le 5 ]
  do
    dhclient -r ens256.$vlanID
    dhclient ens256.$vlanID -1 -timeout 5

# Basic ping heartbeat - deprecated.
#    ping 192.168.1.11 -c 1
    
    status=($?)
    dhclient -r ens256.$vlanID
    
## loop successful heartbeats
    if [ $status -eq 0 ]
      then
         now=$(date)
         echo -------------------------------------- >> $log
         echo This unit is in standby mode  >> $log
         echo Heartbeat Successful - i = $i ----- $now >> $log
         echo -------------------------------------- >> $log
         echo --------------------------------------
         echo This unit is in standby mode
         echo Heartbeat Successful - i = $i -----
         echo --------------------------------------
         echo "Standby" > woc_status.woc
         sleep 5
         i=0
      else
         ((i=i+1))
         now=$(date)
         echo -------------------------------------- >> $log
         echo "Warning $i failed heartbeat attempts through primary WOC -" $now >> $log
         echo DHCP status code = $status >> $log
         echo "At 6 failed attempts this WOC will take over as primary" >> $log
         echo -------------------------------------- >> $log
         echo --------------------------------------
         echo "Warning $i failed heartbeat attempts through primary WOC -"
         echo DHCP status code = $status
         echo "At 6 failed attempts this WOC will take over as primary"
         echo --------------------------------------
         sleep 1

# removed the sleep delay - if the DHCP failes it already has a timeout of 5 seconds before this logic is called.
#         sleep 2

      fi
done

## build script for WOC
echo $i unsuccessful attempts to through primary WOC. >> $log
echo Master Down - This unit is now primary $date >> $log
echo $i unsuccessful attempts to through primary WOC.
echo Master Down - This unit is now primary $date
echo "Primary" > /root/wi-oc/woc_status.woc

#enable the bridge to usurp the failed unit.
#ip link set ens224 up
ip link set br0 up
#systemctl stop firewalld.service

echo This WOC is primary - Monitoring status of backup $(date) >> $log
echo This WOC is primary - Monitoring status of backup $(date)

# Post userpation monitoring of secondary WOC.
while [ $j -le 1 ]
  do
    dhclient -r ens256.$vlanID
    dhclient ens256.$vlanID -1 -timeout 5
    dhclient -r ens256.$vlanID
    bstatus=($?)
      if [ $bstatus -eq 0 ]
        then
          ((j=j+1))
          echo Some other device on the network segment is providing DHCP service, perhaps the partner WOC? >> $log
          echo Some other device on the network segment is providing DHCP service, perhaps the partner WOC?
        else
          j=0
          echo "Primary" > woc_status.woc
      fi
  done

echo "Partner unit has usurped as primary, rebooting this unit and entering standby"  >> $log
echo "Partner unit has usurped as primary, rebooting this unit and entering standby"

#reboot now

exit

