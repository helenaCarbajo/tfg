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

tmp=$(virsh net-dhcp-leases $net $mac)

until [[ "$tmp" =~ $mac ]]; do
	tmp=$(virsh net-dhcp-leases $net $mac)
	sleep 1
done 

#ip=$(virsh net-dhcp-leases $net $mac)
#ip=$(virsh net-dhcp-leases $net $mac | awk '$5 ~ "192" { print $5 }')

ip=$(virsh net-dhcp-leases $net $mac | awk '$5 ~ "192" { print $5 }' | cut -d'/' -f 1)

echo $ip


sudo iptables -t nat -A PREROUTING -s 192.168.200.1 -j DNAT --to-destination $ip

echo "New rule added correctly to iptables"


#echo $ip

