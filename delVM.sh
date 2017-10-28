#!/bin/bash


newVM="newVM"

virsh shutdown $newVM

if [ $? -ne 0 ]
then 
	virsh destroy $newVM
fi

virsh undefine $newVM


#Delete disk image

rm -rf ../Development/matrix/images/newVM.qcow2

