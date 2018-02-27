#!/bin/bash

#Variables definitions

machine="newVM_"
pathTemplate="/home/helena/Tfg/Final/matrix/templates/centosTemplate.xml"
pathImage="/home/helena/Tfg/Final/matrix/images/"
file="/home/helena/Tfg/Scripts/dumpedXml.xml"
net="matrix"
attackerIp=$1
MAX_VM=2


func_check_vm_num(){
	set -
	echo "Exec: func_check_vm_num"
	#Assign right name to new virtual machine
	count=$(ls $pathImage | wc -l)
	echo $count
	if [ $count -ge $MAX_VM ]
	then
		echo "Ya se ha alcanzo el maximo numero de maquinas virtuales"
		echo "Se eligira una al azar"
		num=$(( ( RANDOM % 2 )  + 1 ))
		machine=$machine$num
		echo $machine
		return 1
	else
		((count++))
		machine=$machine$count
		echo $machine
		return 2
	fi
	set +
}


#Function to launch a new virtual machine
func_clone_machine(){
	
	echo "Exec: func_clone_machine"
	newVM="$1"

	#Clone machine from template

	virt-clone --original-xml $pathTemplate --name $newVM --file ${pathImage}${newVM}
	echo "Getting information of new machine"

	virsh dominfo $newVM

	virsh start $newVM

}

func_getIp(){
	#echo "Exec: func_getIp"
	newVM="$1"

	#read MAC value of virtual machine

	virsh dumpxml $newVM > $file

	mac=$(xmllint --xpath 'string(//domain/devices/interface/mac/@address)' $file )

	#echo $mac

	#Look for IP address lease from MAC

	tmp=$(virsh net-dhcp-leases $net $mac)

	until [[ "$tmp" =~ $mac ]]; do
        	tmp=$(virsh net-dhcp-leases $net $mac)
        	sleep 1
	done

	ip=$(virsh net-dhcp-leases $net $mac | awk '$5 ~ "192" { print $5 }' | cut -d'/' -f 1)

	echo $ip
	
	#return $ip

}

func_setup_route(){
SUBNET="$1"
ROUTER="$2"
MACHINE="$3"
echo $MACHINE
echo "Exec: ssh root@${MACHINE} ip addr add $SUBNET dev eth0"
ssh -o StrictHostKeyChecking=no root@$MACHINE ip addr add $SUBNET dev eth0
echo "Exec: ssh root@$MACHINE ip r add default via $ROUTER"
ssh -o StrictHostKeyChecking=no root@$MACHINE ip r add default via $ROUTER

}

exec_remote_cmd(){
attackIp="$1"
dstIp="$2"

ssh root@router /bin/bash /usr/bin/addIpRule.sh $attackIp $dstIp

}



main(){
	echo "Exec: main"
	func_check_vm_num
	if [ $? = 2 ]
	then
		func_clone_machine $machine
	fi
	func_getIp $machine
	newIp=$(func_getIp $machine)
	echo $newIp
	func_setup_route "192.168.10/24" "192.168.10.150" "$newIp"
	#func_setup_route "192.168.10/24" "192.168.10.150" "192.168.10.169"
	exec_remote_cmd $attackerIp $newIp 
	echo "Execution completed"
}


main "$&" >> /tmp/launchMachine.log 
