#!/bin/bash

#Variables definitions

newVM="newVM"
pathTemplate="/home/helena/Tfg/Development/inside/templates/centosTemplate.xml"
pathImage="/home/helena/Tfg/Development/inside/images/newVM.qcow2"
file="dumpedXml.xml"
net="insideNetwork"

#Clone machine from template

virt-clone --original-xml $pathTemplate --name $newVM --file $pathImage

virsh dominfo $newVM

virsh start $newVM

#read MAC value of virtual machine

virsh dumpxml $newVM > $file

mac=$(xmllint --xpath 'string(//domain/devices/interface/mac/@address)' $file )

echo $mac

#Look for IP address lease from MAC


ip=$(virsh net-dhcp-leases $net $mac | awk 'NF > 0 ' )

while [ $? -ne 0 ]
do
	ip=$(virsh net-dhcp-leases $net $mac)
done

echo $?

echo $ip

