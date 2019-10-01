#!/bin/bash

VERSION=%%%BE_VERSION%%%

VERSION_REGEX=([0-9]\.[0-9]).*
if [[ $VERSION =~ $VERSION_REGEX ]]
then
	SHORT_VERSION=${BASH_REMATCH[1]};
else
	echo "Improper version.Aborting."
	exit 1
fi

BE_HOME=/opt/tibco/be/$SHORT_VERSION
TRA_FILE=$BE_HOME/bin/be-engine.tra
CURRENT_DIR=$(pwd)
BE_PROPS_FILE=beprops_all.props
APP_HOME=/opt/tibco/be/application

TRA_FILE=$BE_HOME/bin/be-engine.tra


export PERL5LIB="/opt/tibco/be/$SHORT_VERSION/cloud/docker/lib"
MAKE_BE_PROPS_RESULT=$(perl -Mbe_docker_run -e "be_docker_run::makeBeProps('$BE_PROPS_FILE','$APP_HOME','$BE_HOME/')")
/bin/cat $BE_PROPS_FILE

COMPONENT_PARSED="${COMPONENT%\"}"
COMPONENT_PARSED="${COMPONENT_PARSED#\"}"

JMX_PORT_PARSED="${JMX_PORT%\"}"
JMX_PORT_PARSED="${JMX_PORT_PARSED#\"}"


if [ "$COMPONENT_PARSED" = "tea" ]; then
  TEA_SERVER_URL_PARSED="${TEA_SERVER_URL%\"}"
  TEA_SERVER_URL_PARSED="${TEA_SERVER_URL_PARSED#\"}"
  
  TEA_AGENT_HOST_PARSED="${TEA_AGENT_HOST%\"}"
  TEA_AGENT_HOST_PARSED="${TEA_AGENT_HOST_PARSED#\"}"
  
  if [[ -z "$TEA_AGENT_HOST_PARSED" ]]; then
 	TEA_AGENT_HOST_PARSED=$(grep $(hostname) /etc/hosts|awk '{print $1}')
  fi

  BE_TEA_AGENT_AUTO_REGISTER_ENABLE_PARSED="${BE_TEA_AGENT_AUTO_REGISTER_ENABLE%\"}"
  BE_TEA_AGENT_AUTO_REGISTER_ENABLE_PARSED="${BE_TEA_AGENT_AUTO_REGISTER_ENABLE_PARSED#\"}"  
  
  BE_TEA_AGENT_MONITORING_ONLY_PARSED="${BE_TEA_AGENT_MONITORING_ONLY%\"}"
  BE_TEA_AGENT_MONITORING_ONLY_PARSED="${BE_TEA_AGENT_MONITORING_ONLY_PARSED#\"}"

  TEA_PROPS_FILE="$BE_HOME/teagent/config/be-teagent.props"
  TRA_FILE="$BE_HOME/teagent/bin/be-teagent.tra"
  
  echo "" >> $TEA_PROPS_FILE 
  echo "be.tea.agent.monitoring.application=$BE_TEA_AGENT_MONITORING_ONLY_PARSED" >> $TEA_PROPS_FILE 
  echo "be.tea.agent.host=$TEA_AGENT_HOST_PARSED" >> $TEA_PROPS_FILE
  echo "be.tea.server.url=$TEA_SERVER_URL_PARSED/tea" >> $TEA_PROPS_FILE
  echo "be.tea.agent.auto.registration.enabled=$BE_TEA_AGENT_AUTO_REGISTER_ENABLE_PARSED" >> $TEA_PROPS_FILE
 
  RUNCMD="./run_teagent.sh $BE_HOME $TRA_FILE"

  TEA_SERVER_USERNAME_PARSED="${TEA_SERVER_USERNAME%}"
  TEA_SERVER_USERNAME_PARSED="${TEA_SERVER_USERNAME_PARSED#\"}"

  TEA_SERVER_PASSWORD_PARSED="${TEA_SERVER_PASSWORD%}"
  TEA_SERVER_PASSWORD_PARSED="${TEA_SERVER_PASSWORD_PARSED#\"}"

  BE_INSTANCE_DISCOVERY_TYPE_PARSED="${BE_INSTANCE_DISCOVERY_TYPE%}"
  BE_INSTANCE_DISCOVERY_TYPE_PARSED="${BE_INSTANCE_DISCOVERY_TYPE_PARSED#\"}"
  PYTHONPATH="$BE_HOME/teagent/cli/python"
  
  BE_INSTANCE_POLLAR_INTERVAL_PARSED="${BE_INSTANCE_POLLAR_INTERVAL%}"
  BE_INSTANCE_POLLAR_INTERVAL_PARSED="${BE_INSTANCE_POLLAR_INTERVAL_PARSED#\"}"
  STACK_NAME_PARSED ="beappstack"
  #If discovery is for aws
  if [[ "$BE_INSTANCE_DISCOVERY_TYPE_PARSED" == "aws" ]]; then
	STACK_NAME_PARSED="${STACK_NAME%}"
    STACK_NAME_PARSED="${STACK_NAME_PARSED#\"}"
 	RUNCMD="${RUNCMD} $TEA_SERVER_URL_PARSED $TEA_SERVER_USERNAME_PARSED  $TEA_SERVER_PASSWORD_PARSED $PYTHONPATH $BE_INSTANCE_POLLAR_INTERVAL_PARSED  $STACK_NAME_PARSED $BE_INSTANCE_DISCOVERY_TYPE_PARSED"
  #If discovery is for k8s
  elif [[ "$BE_INSTANCE_DISCOVERY_TYPE_PARSED" == "k8s" ]]; then #If discovery is for k8s
		BE_TEA_AGENT_URL_PARSED="${BE_TEA_AGENT_URL%}"
        BE_TEA_AGENT_URL_PARSED="${BE_TEA_AGENT_URL_PARSED#\"}"
        RUNCMD="${RUNCMD}  $TEA_SERVER_URL_PARSED $TEA_SERVER_USERNAME_PARSED  $TEA_SERVER_PASSWORD_PARSED $PYTHONPATH $BE_INSTANCE_POLLAR_INTERVAL_PARSED $BE_TEA_AGENT_URL_PARSED $BE_INSTANCE_DISCOVERY_TYPE_PARSED"
  fi
else
	
	if [ "$COMPONENT_PARSED" = "rms" ]; then
  		TRA_FILE=$BE_HOME/rms/bin/be-rms.tra
		mkdir -p $BE_HOME/eclipse-platform/eclipse/dropins && echo "path=/opt/tibco/be/5.6/studio" > $BE_HOME/eclipse-platform/eclipse/dropins/TIBCOBusinessEvents-Studio-plugins.link
	fi

	if [ -z "$JMX_PORT_PARSED" ]; then
    	JMX_PORT_PARSED=5555
	fi
	echo "JMX_PORT":$JMX_PORT_PARSED
	echo "BE_HOME:"$BE_HOME	
	echo "TRA File:"$TRA_FILE
	echo "Engine Name:"$ENGINE_NAME
	if [ "$CDD_FILE" = "no-default" ]; then
  		echo "ERROR: Cannot start BE engine. No CDD specified"
  		exit
	fi
	if [ "$EAR_FILE" = "no-default" ]; then
  		echo "ERROR: Cannot start BE engine. No EAR file specified"
  		exit
	fi

	AS_LISTEN_URL=tcp://`hostname`:50000
	AS_REMOTE_LISTEN_URL=tcp://`hostname`:50001
	if [ "$AS_DISCOVER_URL" = "self" ]; then	
  		AS_DISCOVER_URL="$AS_LISTEN_URL"
	fi

	echo "CDD File:"$CDD_FILE
	echo "Processing Unit:"$PU
	echo "EAR File:"$EAR_FILE
	echo "AS Discover URL:"$AS_DISCOVER_URL
	echo "AS Listen URL:"$AS_LISTEN_URL

	UPDATE_CDD_RESULT=$(perl -Mbe_docker_run -e "be_docker_run::updateCddFile('$CDD_FILE','/mnt/tibco/be/data-store','/mnt/tibco/be/logs','$SHORT_VERSION','$BE_HOME/')")
	
	if [ "$LOG_LEVEL" != "na" ]; then
  		#Putting tra entry for log level
  		LOG_LEVEL=${LOG_LEVEL//:/\\:}
  		LOG_LEVEL=${LOG_LEVEL//,/%PSP%}
  		echo "java.property.be.trace.roles=$LOG_LEVEL" >> $TRA_FILE 
	fi

	
	AS_PROXY_NODE_PARSED="${AS_PROXY_NODE%\"}"
	AS_PROXY_NODE_PARSED="${AS_PROXY_NODE_PARSED#\"}"

	#checking for remote mode
	if [[ "$AS_PROXY_NODE_PARSED" = "true" ]]; then
 		echo "java.property.be.engine.cluster.as.remote.listen.url=$AS_REMOTE_LISTEN_URL" >> $TRA_FILE
  		RUNCMD="$BE_HOME/bin/be-engine --propFile $TRA_FILE --propVar AS_DISCOVER_URL=$AS_DISCOVER_URL --propVar AS_LISTEN_URL=$AS_LISTEN_URL --propVar AS_REMOTE_LISTEN_URL=$AS_REMOTE_LISTEN_URL --propVar jmx_port=$JMX_PORT_PARSED -n $ENGINE_NAME -c $CDD_FILE -u $PU -p $BE_PROPS_FILE $EAR_FILE"
	else
 		RUNCMD="$BE_HOME/bin/be-engine --propFile $TRA_FILE --propVar AS_DISCOVER_URL=$AS_DISCOVER_URL --propVar AS_LISTEN_URL=$AS_LISTEN_URL --propVar jmx_port=$JMX_PORT_PARSED -n $ENGINE_NAME -c $CDD_FILE -u $PU -p $BE_PROPS_FILE $EAR_FILE"
	fi
fi


#adding host addr entry
if [ -z "$DOCKER_HOST" ]; then
	DOCKER_HOST=$(grep $(hostname) /etc/hosts|awk '{print $1}')	
fi
echo "java.property.java.rmi.server.hostname $DOCKER_HOST" >> $TRA_FILE

#Get java extended properties and append jvm stack size,override java extended properties and tra properties
val="$(grep  -v '#' $TRA_FILE | grep 'java.extended.properties')"
blank=""
INITIAL_HEAP_SIZE="$(grep 'tra.java.heap.size.initial' $BE_PROPS_FILE)";
MAX_HEAP_SIZE="$(grep 'tra.java.heap.size.max' $BE_PROPS_FILE)";
STACK_SIZE="$(grep 'tra.java.stack.size' $BE_PROPS_FILE)";
JAVA_EXTENDED_PROPERTIES="$(grep 'tra.java.extended.properties' $BE_PROPS_FILE)";

if [[  -n "$JAVA_EXTENDED_PROPERTIES" ]]; then 
	val="${JAVA_EXTENDED_PROPERTIES/tra./$blank}"
fi

#Stack size
if [[ -n "$STACK_SIZE" ]]; then 
	output="${STACK_SIZE/tra.java.stack.size=/$blank}"
	output="${output##*( )}"
	output="${output%%*( )}"
   	val="$val -Xss$output"
fi


#add properties prefixed with tra
args="$(grep '^tra' $BE_PROPS_FILE)";
for arg in $args
do
	props="";
	if [[ $arg == tra* ]]; then
    		 if [[ ! ("$arg" == tra.java.stack.size=* || "$arg" == tra.java.heap.size.max=* || "$arg" == tra.java.heap.size.initial=* || "$arg" == tra.java.extended.properties=* ) ]]; then
 	 			props="${arg/tra./$blank}"
         		echo $props >> $TRA_FILE
             	fi
  	fi
done

echo $val >> $TRA_FILE

#Intial Heap size
if [[  -n "$INITIAL_HEAP_SIZE" ]]; then 
    	INITIAL_HEAP_SIZE="${INITIAL_HEAP_SIZE/tra./$blank}"
    	echo $INITIAL_HEAP_SIZE >> $TRA_FILE
fi

#Max heap size	
if [[  -n "$MAX_HEAP_SIZE" ]]; then 
    	MAX_HEAP_SIZE="${MAX_HEAP_SIZE/tra./$blank}"
    	echo $MAX_HEAP_SIZE >> $TRA_FILE
fi


echo "$RUNCMD"
exec $RUNCMD
