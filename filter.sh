#!/bin/bash
newVM="newVM"

net="insideNetwork"
file="dumpedXml.xml"

virsh dumpxml $newVM > $file

mac=$(xmllint --xpath 'string(//domain/devices/interface/mac/@address)' $file )

echo $mac



ip=$(virsh net-dhcp-leases $net $mac | awk '$5 ~ "192" { print $5 }' | cut -d'/' -f 1)

echo $ip


sudo iptables -t nat -A PREROUTING -s 192.168.200.1 -j DNAT --to-destination $ip

echo "New rule added correctly to iptables"
