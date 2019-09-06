#!/usr/bin/env python

import json
import sys
import os
import argparse
import requests
from requests import Request
from subprocess import check_output
from requests.auth import HTTPBasicAuth
from requests.exceptions import ConnectionError
import time
import logging
from subprocess import CalledProcessError

#Check whether given key exists in array or not
def isKeyExist(key,arr):
	if key in arr:
		return True
	return False

#discover containers
def discoverInstanceDatails(appManagementFilePath):
  logger.info("****************************** Get the container host name and ip address ******************************")
  try:
    output = check_output(["cat","/var/run/secrets/kubernetes.io/serviceaccount/token"])
    headers={'Content-Type' : 'application/jsoncharset=UTF-8','Authorization': 'Bearer '+output}
    result = requests.get("https://kubernetes.default.svc/api/v1/pods",headers=headers,verify="/var/run/secrets/kubernetes.io/serviceaccount/ca.crt")
    result=json.loads(result.content) 
  except CalledProcessError as e:
	logger.error(str(e))
  
  if result and isKeyExist("items",result):
          items=result["items"]
          if items and len(items)>0:               
	  	for item in items:			
	      		if(isKeyExist("status",item) and isKeyExist("status",item)  and "Running"==item["status"]["phase"] and "env" in item["spec"]["containers"][0]):
	        	  podname=item["metadata"]["name"]
			  podIp=item["status"]["podIP"]
			  environment=item["spec"]["containers"][0]["env"]
			  puname=getEnvironmentVariable(environment,'PU')                         
                          #Get JMX details
                    	  jmxport=getEnvironmentVariable(environment,'JMX_PORT')      
	                  if(not jmxport):
        	                jmxport=5555 
			  if(puname and jmxport>0):                                  
				  jmxusername=getEnvironmentVariable(environment,'JMX_USERNAME')
                    		  jmxpassword=getEnvironmentVariable(environment,'JMX_PASSWORD')
				  appname=getEnvironmentVariable(environment,'APPLICATION_NAME')
                    		  if(not appname):
				  	appname=item["spec"]["containers"][0]["image"]
                                        parts=appname.split('/')
	                          	appname=parts[len(parts)-1]
	                    	  	appname=appname.replace('.','_').replace(':','_') 

				  machinename=podIp+"_"+podname 
                        	  instancename="Instance_"+podIp+"_"+podname
                                  logger.info("Adding Machine %s:" %machinename)
                            	  addMachine(machinename,podIp,appManagementFilePath)
                                                 
                                  logger.info("Adding Application %s:" %appname)
                                  addApplication(appname,appManagementFilePath)

                                  logger.info("Adding Instance  %s:" %instancename)
                                  addInstance(appname,machinename,instancename,str(jmxport),jmxusername,jmxpassword,appManagementFilePath,puname)

			   
  
#Add machine
def addMachine(machinename,hostname,appManagementFilePath):
    command=appManagementFilePath+" docker_addmachine -m \""+machinename+"\" -i \""+hostname+"\""
    logger.info("Executing :"+command)
    os.system(command)

#Add instance
def addInstance(appname,machinename, instancename,jmxport,jmxusername,jmxpassword,appManagementFilePath,puname):
    command=appManagementFilePath+ " docker_createinstance -d \""+appname+"\" -i \""+instancename+"\" -m \""+machinename+"\" -p "+jmxport+" -ju \""+jmxusername+"\" -jp \""+jmxpassword+"\" -u \""+ puname+"\""
    logger.info("Executing :"+command)
    os.system(command)
     
#Add application   
def addApplication(appname,appManagementFilePath):
    command=appManagementFilePath+" docker_createdeployment -d   \""+appname+"\""
    logger.info("Executing :"+command)
    os.system(command)    
    
#Get the environment variable value
def getEnvironmentVariable(environment,name):
    for env  in environment:
        if(env['name']==name):
            return env['value']
    return ""

def registerTEAgent(serverURL,username,userPwd,teaagenturl):
	url=serverURL+"/teas/task"
	teaagenturl=teaagenturl+"/beTeaAgent"
	payload='{"operation":"registerAgentWithReferenceReturn","params":{"name":"BE","url":\"'+teaagenturl+'\","description":""},"methodType":"UPDATE","objectId":":tea::agents:"}'
	headers={ 'Accept':'application/json, text/plain, */*','Content-Type' : 'application/jsoncharset=UTF-8' }
	success =False
	while (not success):
		try:
			resp=requests.put(url, data=payload,auth=HTTPBasicAuth(username,userPwd),headers =headers )
			if resp.status_code != 200:
				message=resp.json()[ 'message' ]
				if "Agent 'BE' is already registered " in message:
					success=True
                                        logger.info(message)
                                else:
                                        logger.error(resp.json())	
			else:
				success=True
				logger.info("TEA agent registered successfully")
		except ConnectionError as e:
			pass
		if not success:	
			time.sleep(30)

	
def main(serverURL, userName, userPwd, sslEnabled, serverCert, clientCert,teaagenturl,pythonpath,pollarinterval):
 logger.info("Python path:"+pythonpath)
 appManagementFilePath="python "+ pythonpath+"/applicationsMgmt.py -t \""+ serverURL +"\" -u \""+ userName +"\" -p \""+ userPwd+"\""
 applications=[]
 machines=[]
 instances=[]
 
 while True:
	try:
		registerTEAgent(serverURL,userName,userPwd,teaagenturl)
                discoverInstanceDatails(appManagementFilePath)	                	   
        except Exception  as e:
		logger.error(str(e))
    	
	time.sleep(int(pollarinterval))	     
                             
def createCommandParser():
    #create the top-level parser
    commandParser = argparse.ArgumentParser(add_help = False, description = 'Applications Management Operations CLI.')
    commandParser.add_argument('-ssl', required = False, default = False, dest = 'sslEnabled', help = 'SSL Enabled')
    commandParser.add_argument('-t', required = True, dest = 'serverurl', help = 'TEA Internal Service Name')
    commandParser.add_argument('-u', required = True, dest = 'userName', help = 'TEA User Name')
    commandParser.add_argument('-p', required = True, dest = 'userPwd', help = 'TEA User Password')    
    commandParser.add_argument('-sc', required = False, default = '', dest = 'serverCert', help = 'Server certificate Path')
    commandParser.add_argument('-cc', required = False, default = '', dest = 'clientCert', help = 'Client certificate Path')
    commandParser.add_argument('-ta', required = True, default = '', dest = 'teaagenturl', help = 'Tea Agent URL')
    commandParser.add_argument('-py', required = True, default = '', dest = 'pythonpath', help = 'Path of the python')
    commandParser.add_argument('-pi', required = True, default = '', dest = 'pollarinterval', help = 'Interval to poll instance discovery')
    return commandParser


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create Command parser
commandParser = createCommandParser()

#Parse the command arguments
command = commandParser.parse_args()

main(command.serverurl, command.userName, command.userPwd, command.sslEnabled, command.serverCert, command.clientCert,command.teaagenturl,command.pythonpath,command.pollarinterval)
