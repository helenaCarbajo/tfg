#!/bin/bash

path="/var/log/snortvm/snort.log"

touch $path
sudo chown syslog $path
sudo chgrp syslog $path
counter=1
while [ $counter -le 10 ]
do
	echo '2017-10-28T16:09:01.350540+02:00 snortvm snort 192.168.100.1 -> 192.168.100.135 Classification: TCP Portscan'  $counter>>$path
	((counter++))
	sleep 5
done
