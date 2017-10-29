#!/bin/bash

#Variables definitions

newVM="newVM_"
pathTemplate="/home/helena/Tfg/Development/matrix/templates/centosTemplate.xml"
pathImage="/home/helena/Tfg/Development/matrix/images/"
file="/home/helena/Tfg/Scripts/dumpedXml.xml"
net="matrix"
attackerIp=$1
targetIp=$2
searchExp=$2.*=$1
echo $searchExp

#Look for the source of the attack IP
while read -r line
do
    tmpIp=$(echo $line | awk -v d1="$1" '{ if ( $4 != "src="d1 && $5 != "src="d1 )  print $4 " " $5 }')
done < <(sudo conntrack -L | grep -E $searchExp)

srcIp=$(echo $tmpIp | cut -d'=' -f 2 | cut -d' ' -f 1)
echo 'The attack comes from the from the following IP:'
echo $srcIp


#Assign right name to new virtual machine
count=$(find $pathImage -maxdepth 1 -name newVM* | wc -l)
echo $count
((count++))

newVM=$newVM$count


#Clone machine from template

virt-clone --original-xml $pathTemplate --name $newVM --file $pathImage$newVM

virsh dominfo $newVM

virsh start $newVM

#read MAC value of virtual machine

virsh dumpxml $newVM > $file

mac=$(xmllint --xpath 'string(//domain/devices/interface/mac/@address)' $file )

echo $mac

#Look for IP address lease from MAC

tmp=$(virsh net-dhcp-leases $net $mac)

until [[ "$tmp" =~ $mac ]]; do
	tmp=$(virsh net-dhcp-leases $net $mac)
	sleep 1
done 

#ip=$(virsh net-dhcp-leases $net $mac)
#ip=$(virsh net-dhcp-leases $net $mac | awk '$5 ~ "192" { print $5 }')

ip=$(virsh net-dhcp-leases $net $mac | awk '$5 ~ "192" { print $5 }' | cut -d'/' -f 1)

echo $ip

sudo iptables -t nat -F PREROUTING

sudo iptables -t nat -A PREROUTING -s $srcIp -j DNAT --to-destination $ip

echo "New rule added correctly to iptables"


#echo $ip

