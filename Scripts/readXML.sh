#!/bin/bash

newVM="newVM"
net="insideNetwork"
file="dumpedXml.xml"
#readvalue

virsh dumpxml $newVM > $file

mac=$(xmllint --xpath 'string(//domain/devices/interface/mac/@address)' $file )


echo $mac

#Look for IP address lease from MAC

ip=$(virsh net-dhcp-leases $net $mac)

echo $ip

echo $?

