#!/bin/bash

#Inicio máquina virtual atacante
virsh start Attacker


#Inicio máquina virtual snortVM
virsh start router


#Inicio maquina virtual intranet
virsh start target

#Se ha iniciado correctamente
echo "El entorno se ha levantado" 

