#!/bin/bash
echo 'Guardando logs temporales en el archivo snort.safe'
cat /var/log/snortvm/snort.log >> /var/log/snortvm/snort.safe
echo 'Eliminando logs temporales'

rm -rf /var/log/snortvm/snort.log

echo 'Limpiando cadena prerouting'
sudo iptables -t nat -F PREROUTING

echo 'Configuracion inicial finalizada'

