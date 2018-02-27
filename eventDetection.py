#!/usr/bin/env python

# coding=utf-8 

#Script to read messages from syslog


import time
import sys
import logging
import logging.handlers
import subprocess
import os.path

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import watchdog.events
class ScanLogging:
	'Class forwarding scanning alerts to rsyslog'

	#filePath = '/var/log/snort/snort.log'
	
	def __init__(self,dir,file):
		self.file = file
		self.cleanEnv()
		self.event_handler = watchdog.events.FileSystemEventHandler()
		self.event_handler.on_modified = self.on_modified
		self.observer = Observer()
		self.observer.schedule(self.event_handler,path=dir, recursive=True)
		self.observer.start()
		print 'Waiting for event'
		self.filePos = None
		self.attackers = []


	def on_modified(self, event):
		if event.src_path != self.file:
			return
		attackerIp, targetIp,empty = self.readFile()
		if empty != None:
			return 
		if self.checkAttackers(attackerIp):
			print "El ataque ya ha sido gestionado"
			return
		else:
			print "Se ha detectado un nuevo ataque"
			#cmd = 'ssh helena@host /bin/bash /home/helena/Tfg/Scripts/launchVM.sh' + ' ' + attackerIp + ' ' + targetIp
			
			cmd = "ssh helena@host /bin/bash /home/helena/Tfg/Scripts/launchMachine.sh" + ' ' + attackerIp
			subprocess.Popen(cmd,shell=True,executable='/bin/bash')	
			print 'Ejecutado comando en host remoto'
			

	def readFile(self):
        	messages = []
		with open(self.file,'r') as fp:
        		if self.filePos is None:
				self.filePos = fp.tell() 
			fp.seek(self.filePos)
			content = fp.read()
			if content == '':
				return None,None,1
			ip1,ip2 = self.process_content(content)
		        self.filePos = fp.tell()		
		fp.close()
        	return ip1,ip2,None

	def process_content(self,content):
		lines = content.split('\n')
		print lines
		ip1 = ''
		ip2 = ''
		for line in lines:
			if '->' not in line:
				continue
			else:
				if 'Portscan' in line:
					cmd="systemctl restart snort"
					subprocess.Popen(cmd,shell=True)
				#print 'LINEA' + line
				ip1,ip2 = self.getIpAddress(line)
			
		return ip1, ip2

	def cleanEnv(self):
		if os.path.isfile(self.file):
			comm='rm -f ' + self.file 
			subprocess.call(comm,shell=True)
			while os.path.isfile(self.file):
				pass
			print "Se ha borrado el fichero"
		comm = 'touch ' + self.file
		subprocess.call(comm,shell=True)
		print "Se ha creado el fichero"

#	def checkNumInstances(self):
#		vms = len(os.listdir('/home/helena/Tfg/Development/matrix/images/'))
#		if vms < self.maxVM:
#			return True
#		else:
#			return False


	def getIpAddress(self,message):
		parts = message.split("->")
		tmp1 = parts[0].rstrip()
		tmp2 = parts[1].rstrip()
		tmp3 = tmp1.split(" ")
		tmp4 = tmp2.split(" ")
		ip1 = tmp3[len(tmp3) - 1]
		ip2 = tmp4[1]
		print ip1, ip2
		return ip1, ip2


	def checkAttackers(self,ip):
		for attacker in self.attackers:
			if attacker == ip:
				return True
		self.attackers.append(ip)
		print self.attackers
		return False


	def stop(self):
		self.observer.stop()
		self.observer.join()

	


scanAlert = ScanLogging('/var/log/snort','/var/log/snort/snort.log')

try:
	while True:
		time.sleep(1)
except KeyboardInterrupt:
	print 'Closing programme'

scanAlert.stop()


