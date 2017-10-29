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

	def __init__(self):
		self.cleanEnv()
		self.event_handler = watchdog.events.FileSystemEventHandler()
		self.event_handler.on_modified = self.on_modified
		self.observer = Observer()
		self.observer.schedule(self.event_handler,path='/var/log/snortvm/', recursive=True)
		self.observer.start()
		print 'Waiting for event'
		self.filePos = None
		self.maxVM = 2
		self.attackers = []

	def on_modified(self, event):
		print "File has been modified"
		message = self.readFile()
		print message
		if "->" not in message:
			return
		attackerIp, targetIp = self.getIpAddress(message)
		if self.checkAttackers(attackerIp):
			print "El ataque ya ha sido gestionado"
			return
		else:
			if self.checkNumInstances():
				print 'Se puede lanzar una nueva maquina'
				cmd = '/home/helena/Tfg/Scripts/launchVM.sh'+' '+ attackerIp + ' ' + targetIp
				subprocess.call(cmd,shell=True,executable='/bin/bash')
			else: 
				print 'Ya hay demasiadas maquinas lanzadas'
				print 'Se reutilizara una maquina'

	def readFile(self):
        	messages = []
        	with open('/var/log/snortvm/snort.log',"ab+") as fp:
        		if self.filePos is None:
				self.filePos = fp.tell() 
			fp.seek(self.filePos)
			line = fp.readline()
                        line = line.rstrip()
                        self.filePos = fp.tell()
        	return line

	def cleanEnv(self):
		comm='./cleanEnv.sh'
		subprocess.call(comm,shell=True)

	def checkNumInstances(self):
		vms = len(os.listdir('/home/helena/Tfg/Development/matrix/images/'))
		if vms < self.maxVM:
			return True
		else:
			return False

	def getIpAddress(self,message):
		parts = message.split("->")
		tmp1 = parts[0].rstrip()
		tmp2 = parts[1].rstrip()
		ip1 = tmp1.split(" ")[3]
		ip2 = tmp2.split(" ")[1]
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

	
scanLogger = ScanLogging()

try:
	while True:
		time.sleep(1)
except KeyboardInterrupt:
	print 'Closing programme'

scanLogger.stop()


