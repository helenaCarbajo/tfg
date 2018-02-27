#!/bin/bash

DIR="/home/helena/Tfg/Final/matrix/images/"
NAME="newVM_"
func_stopMachine(){
	virsh shutdown $1
	echo "Se ha apagado la maquina $1"
}


func_destroyMachine(){
	virsh destroy $1
	echo "Se ha destruido la maquina $1"
}

func_removeMachine(){
	virsh undefine $1
	echo "Se ha eliminado la maquina $1"
}

func_removeFile(){
	echo $1
	rm -f $1
}

main(){
	count=$(ls $DIR | wc -l)
	while [ "$count" !=  "0" ]
	do
		echo $count
		func_stopMachine $NAME$count
		func_destroyMachine $NAME$count
		func_removeMachine $NAME$count 	 
		func_removeFile $DIR$NAME$count
		count=$(ls $DIR | wc -l)
	done
}

main "$&" >> /tmp/cleanAll.log

