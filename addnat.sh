#!/bin/bash

pathImage="/home/helena/Tfg/Development/matrix/images/"
file="/home/helena/Tfg/Scripts/dumpedXml.xml"
net="matrix"
vm="newVM_"

count=$(find $pathImage -maxdepth 1 -name newVM* | wc -l)
echo $count


#Elegir una de las maquinas virtuales disponibles
num=$(( (RANDOM % $count) +1 ))
echo $num

vm=$vm$num
echo $vm
#Look for the IP of the machine selected
virsh dumpxml $vm > $file

mac=$(xmllint --xpath 'string(//domain/devices/interface/mac/@address)' $file )
echo $mac

ip=$(virsh net-dhcp-leases $net $mac | awk -v d1=$mac '{ if ( $3 == d1 ) print $5 }' | cut -d'/' -f 1)
echo $ip

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

sudo iptables -t nat -A PREROUTING -s $srcIp -j DNAT --to-destination $ip

echo "New rule added correctly to iptables"

