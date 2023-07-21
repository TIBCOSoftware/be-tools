#!/usr/bin/env python

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

import boto3
import json
import sys
import os
import argparse
import time
import logging
from subprocess import check_output

#Get the task defination
def getTaskDefinitions(clustername,launchType):
   logger.info("****************************** Get the service details and task definations ******************************")
   services=get_services(clustername,launchType)
   taskDefinitions=[]
   if(services):
       for service in services:
           if(service!=None and 'ACTIVE' == service['status'] and int(service['runningCount'])>0 and service['launchType']==launchType ):
               taskDefinitions.append(service['taskDefinition']);
   return taskDefinitions;

#Add machine
def addMachine(machinename,hostname,appManagementFilePath):
    command=appManagementFilePath+" docker_addmachine -m \""+machinename+"\" -i \""+hostname+"\"";
    logger.info("Executing :"+command)
    os.system(command)

#Add instance
def addInstance(appname,machinename, instancename,jmxport,jmxusername,jmxpassword,appManagementFilePath):
    command=appManagementFilePath+ " docker_createinstance -d \""+appname+"\" -i \""+instancename+"\" -m \""+machinename+"\" -p "+jmxport+" -ju \""+jmxusername+"\" -jp \""+jmxpassword+"\""
    logger.info("Executing :"+command)
    os.system(command)

#Add application
def addApplication(appname,appManagementFilePath):
    command=appManagementFilePath+" docker_createdeployment -d   \""+appname+"\"";
    logger.info("Executing :"+command)
    os.system(command)

#Get the environment variable value
def getEnvironmentVariable(environment,name):
    for env  in environment:
        if(env['name']==name):
            return env['value'];
    return ""
def json_converter(o):
    return o.__str__()

#get all tasks
def get_tasks(clustername):
    taskArns=[]
    response=ecs_client.list_tasks(cluster=clustername)
    if(response):
        task_list=response['taskArns']
        for taskarn in task_list:
            taskArns.append(taskarn)
    tasks = ecs_client.describe_tasks(cluster=clustername,tasks=taskArns)
    return tasks['tasks']


#get services
def get_services(clustername,launchType):
    serviceArns=[]
    response=ecs_client.list_services(cluster=clustername,launchType=launchType)
    if(response):
        service_list=response['serviceArns']
        for servicearn in service_list:
            serviceArns.append(servicearn)
    services= ecs_client.describe_services(cluster=clustername,services=serviceArns)
    return services['services']

def process_taskDefinition(taskDefinition,address,appManagementFilePath):

    if(taskDefinition!=None and 'ACTIVE' == taskDefinition['status']):
        name=taskDefinition['containerDefinitions'][0]['name'];
        environment=taskDefinition['containerDefinitions'][0]['environment'];
        puname=getEnvironmentVariable(environment,'PU');
        logger.info("puname: ",puname)
        #Get JMX details
        jmxport=getEnvironmentVariable(environment,'JMX_PORT');
        if(not jmxport):
            jmxport=5555
        jmxusername=getEnvironmentVariable(environment,'JMX_USERNAME');
        jmxpassword=getEnvironmentVariable(environment,'JMX_PASSWORD');
        appname=getEnvironmentVariable(environment,'APPLICATION_NAME');
        if(not appname):
            appname=taskDefinition['containerDefinitions'][0]['image']
        appname=appname.split('/')[1]
        appname=appname.replace('.','_').replace(':','_');
        logger.info("jmxport: ",jmxport)
        if(puname and int(jmxport)>0):
            host=address
            machinename=address+"_"+name;
            instancename="Instance_"+address+"_"+name
            logger.info("Adding Machine "+machinename);
            addMachine(machinename,address,appManagementFilePath)
            logger.info("Adding Application "+appname);
            addApplication(appname,appManagementFilePath)
            logger.info("Adding Instance  "+instancename);
            addInstance(appname,machinename,instancename,str(jmxport),jmxusername,jmxpassword,appManagementFilePath)


#Check whether given key exists in array or not
def isKeyExist(key,arr):
	if key in arr:
		return True
	return False

'''
Main method of the application
'''
def main(serverURL, userName, userPwd, sslEnabled, serverCert, clientCert,clustername,launchType,pythonpath,pollarinterval):
    appManagementFilePath="python "+ pythonpath+"/applicationsMgmt.py -t \""+ serverURL +"\" -u \""+ userName +"\" -p \""+ userPwd+"\" -ssl \""+ sslEnabled+"\" -sc \""+ serverCert+"\" -cc \""+ clientCert+"\"";

    while True:

        try:
            taskDefinitions=getTaskDefinitions(clustername,launchType)
            tasks=get_tasks(clustername)
            for task in tasks:
                if(task['launchType']==launchType and  'RUNNING'==task['desiredStatus']):
                    containers=task['containers']
                    privateIp=containers[0]['networkInterfaces'][0]['privateIpv4Address']
                    logger.info("ipAddress: ",privateIp)
                    taskDefinitionArn=task['taskDefinitionArn']
                    if(isKeyExist(taskDefinitionArn,taskDefinitions)):
                        response=ecs_client.describe_task_definition(taskDefinition=taskDefinitionArn)
                        if(response):
                            taskDefinition=response['taskDefinition']
                            if(taskDefinition):
                                process_taskDefinition(taskDefinition,privateIp,appManagementFilePath)

        except Exception  as e:
            logger.error(str(e))
    
        time.sleep(int(pollarinterval))

def createCommandParser():
    #create the top-level parser
    commandParser = argparse.ArgumentParser(add_help = False, description = 'Applications Management Operations CLI.')
    commandParser.add_argument('-ssl', required = False, default = False, dest = 'sslEnabled', help = 'SSL Enabled')
    commandParser.add_argument('-t', required = True, dest = 'serverURL', help = 'TEA Server URL')
    commandParser.add_argument('-u', required = True, dest = 'userName', help = 'TEA User Name')
    commandParser.add_argument('-p', required = True, dest = 'userPwd', help = 'TEA User Password')
    commandParser.add_argument('-sc', required = False, default = '', dest = 'serverCert', help = 'Server certificate Path')
    commandParser.add_argument('-cc', required = False, default = '', dest = 'clientCert', help = 'Client certificate Path')
    commandParser.add_argument('-c', required = True, default = 'ALL', dest = 'clustername', help = 'AWS Fargate Cluster Name')
    commandParser.add_argument('-lt', required = True, default = 'FARGATE', dest = 'launchType', help = 'AWS ECS Cluster Launch Type')
    commandParser.add_argument('-py', required = True, default = '', dest = 'pythonpath', help = 'Path of the python')
    commandParser.add_argument('-pi', required = True, default = '30', dest = 'pollarinterval', help = 'Interval to poll instance discovery')
    return commandParser;

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

#ECS cluster name
ecs_client=client = boto3.client('ecs');

# Create Command parser
commandParser = createCommandParser()

#Parse the command arguments
command = commandParser.parse_args()

main(command.serverURL, command.userName, command.userPwd, command.sslEnabled, command.serverCert, command.clientCert,command.clustername,command.launchType,command.pythonpath,command.pollarinterval);
