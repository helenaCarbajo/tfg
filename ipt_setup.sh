#!/bin/bash


#Define path to files
FILE_PATH="/home/helena/Tfg/Files/iptables.txt"

sudo iptables-restore $FILE_PATH

echo "iptables se ha configurado correctamente" 

