#!/usr/bin/env python

import boto3
import json
import sys
import os
import argparse
import time
from subprocess import check_output


#Get the cluster name
def getClusterName(stackName):
 print "****************************** Get the cluster name ******************************"
 response = cloudformation_client.describe_stack_resource(
    StackName=stackName,
    LogicalResourceId='EcsCluster'
 )
 return response["StackResourceDetail"]["PhysicalResourceId"];
  

#discover containers
def discoverContainers():
  print "****************************** Get the container host name and ip address ******************************"

  result = check_output(["sudo","weave", "report","-f","\"{{json .DNS.Entries}}\""])
  result=result[1:-1]; 
  entries=json.loads(result);
  ip_host_map={}
  for entry in entries:
      if("scope.weave.local."!=entry["Hostname"] and 0== entry["Tombstone"]):
           address=str(entry["Address"]);
           hostname=str(entry["Hostname"]);
           ip_host_map[address]=hostname;            
  
  return ip_host_map;

#Get the task defination
def getTaskDefinitions(clustername):   
   print "****************************** Get the service details and task definations ******************************"
   response=ecs_client.list_services(cluster=clustername);  
   serviceArns=response["serviceArns"];  
   taskDefinitions=[];
   if(serviceArns):
       response=ecs_client.describe_services(cluster=clustername,services=serviceArns)
       if(response):
         services=response['services'];
         if(services):
           for service in services:
              if(service and 'ACTIVE' == service['status']):
                  taskDefinitions.append(service['taskDefinition']);
   return taskDefinitions;  
 
#Add machine
def addMachine(machinename,hostname,appManagementFilePath):
    command=appManagementFilePath+" docker_addmachine -m \""+machinename+"\" -i \""+hostname+"\"";
    print "Executing :"+command
    os.system(command)

#Add instance
def addInstance(appname,machinename, instancename,jmxport,jmxusername,jmxpassword,appManagementFilePath):
    command=appManagementFilePath+ " docker_createinstance -d \""+appname+"\" -i \""+instancename+"\" -m \""+machinename+"\" -p "+jmxport+" -ju \""+jmxusername+"\" -jp \""+jmxpassword+"\""
    print "Executing :"+command
    os.system(command)
     
#Add application   
def addApplication(appname,appManagementFilePath):
    command=appManagementFilePath+" docker_createdeployment -d   \""+appname+"\"";
    print "Executing :"+command
    os.system(command)    
    
#Get the environment variable value
def getEnvironmentVariable(environment,name):
    for env  in environment:
        if(env['name']==name):
            return env['value'];
    return ""

def main(serverURL, userName, userPwd, sslEnabled, serverCert, clientCert,stackName,pythonpath,pollarinterval):
 appManagementFilePath="python "+ pythonpath+"/applicationsMgmt.py -t \""+ serverURL +"\" -u \""+ userName +"\" -p \""+ userPwd+"\"";
 clustername=getClusterName(stackName);
 applications=[];
 machines=[];
 instances=[];
 while True:
   ip_host_map=discoverContainers();
   for key, value in ip_host_map.items():
     address=key
     taskDefinitions=getTaskDefinitions(clustername);
     if(taskDefinitions):
         for taskDefinition in taskDefinitions:
          response=ecs_client.describe_task_definition(taskDefinition=taskDefinition); 
    
          if(response):
            taskDefinition=response['taskDefinition'];
            if(taskDefinition):
                if(taskDefinition and 'ACTIVE' == taskDefinition['status']):
                    name=taskDefinition['containerDefinitions'][0]['name'];
                    environment=taskDefinition['containerDefinitions'][0]['environment'];
                    puname=getEnvironmentVariable(environment,'PU');
                    
                    #Get JMX details
                    jmxport=getEnvironmentVariable(environment,'JMX_PORT');      
                    if(not jmxport):
                        jmxport=5555             
                    
                    jmxusername=getEnvironmentVariable(environment,'JMX_USERNAME');
                    jmxpassword=getEnvironmentVariable(environment,'JMX_PASSWORD');
                    
                    appname=getEnvironmentVariable(environment,'APPLICATION_NAME');
                    if(not appname):
                        appname=taskDefinition['containerDefinitions'][0]['image'];
                        
                    appname=appname.split('/')[1];
                    appname=appname.replace('.','_').replace(':','_');                 
                   
                    if(puname and jmxport>0):
                        host=name+""+weave+""+local; 
                        machinename=address+"_"+name; 
                        instancename="Instance_"+address+"_"+name
                        if(host==value):	
                            print ("Adding Machine %s:" %machinename);
                            addMachine(machinename,address,appManagementFilePath)
                                                 
                            print ("Adding Application %s:" %appname);
                            addApplication(appname,appManagementFilePath)

                            print ("Adding Instance  %s:" %instancename);
                            addInstance(appname,machinename,instancename,str(jmxport),jmxusername,jmxpassword,appManagementFilePath)

   time.sleep(pollarinterval)                        

                             
def createCommandParser():
    #create the top-level parser
    commandParser = argparse.ArgumentParser(add_help = False, description = 'Applications Management Operations CLI.')
    commandParser.add_argument('-ssl', required = False, default = False, dest = 'sslEnabled', help = 'SSL Enabled')
    commandParser.add_argument('-t', required = True, dest = 'serverURL', help = 'TEA Server URL')
    commandParser.add_argument('-u', required = True, dest = 'userName', help = 'TEA User Name')
    commandParser.add_argument('-p', required = True, dest = 'userPwd', help = 'TEA User Password')    
    commandParser.add_argument('-sc', required = False, default = '', dest = 'serverCert', help = 'Server certificate Path')
    commandParser.add_argument('-cc', required = False, default = '', dest = 'clientCert', help = 'Client certificate Path')
    commandParser.add_argument('-s', required = False, default = '', dest = 'stackname', help = 'Stack name of the AWS Cluster')
    commandParser.add_argument('-py', required = True, default = '', dest = 'pythonpath', help = 'Path of the python')
    commandParser.add_argument('-pi', required = True, default = '30', dest = 'pollarinterval', help = 'Interval to poll instance discovery')
    return commandParser;

  

ecs_client=client = boto3.client('ecs');
cloudformation_client = boto3.client('cloudformation');
weave=".weave";
local=".local."

# Create Command parser
commandParser = createCommandParser()

#Parse the command arguments
command = commandParser.parse_args()

main(command.serverURL, command.userName, command.userPwd, command.sslEnabled, command.serverCert, command.clientCert,command.stackname,command.pythonpath,command.pollarinterval);
