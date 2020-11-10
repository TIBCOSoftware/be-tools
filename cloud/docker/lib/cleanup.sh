cd /opt/tibco/be/$BE_SHORT_VERSION/bin/

if [ "$COMPONENT" != "tea" ]
then
    echo "java.property.be.engine.cluster.as.discover.url=%AS_DISCOVER_URL%" >> be-engine.tra
    echo "java.property.be.engine.cluster.as.listen.url=%AS_LISTEN_URL%" >> be-engine.tra
    echo "java.property.be.engine.cluster.as.remote.listen.url=%AS_REMOTE_LISTEN_URL%" >> be-engine.tra
fi

echo "java.property.com.sun.management.jmxremote.rmi.port=%jmx_port%" >> be-engine.tra

mkdir -p /tibco_home/tibcojre64
mkdir -p /tibco_home/be/${BE_SHORT_VERSION}/bin

if [ ! -z "$AS_SHORT_VERSION" ]
then 
    mkdir -p /tibco_home/as/${AS_SHORT_VERSION}
    cp -r /opt/tibco/as/${AS_SHORT_VERSION}/lib /tibco_home/as/${AS_SHORT_VERSION}
fi

if [ ! -z "$FTL_SHORT_VERSION" ]
then 
    mkdir -p /tibco_home/ftl/${FTL_SHORT_VERSION}
    rm -r /opt/tibco/ftl/${FTL_SHORT_VERSION}/lib/simplejson
    cp -r /opt/tibco/ftl/${FTL_SHORT_VERSION}/lib /tibco_home/ftl/${FTL_SHORT_VERSION}
    sed -i "s@tibco.env.FTL_HOME=@tibco.env.FTL_HOME=/opt/tibco/ftl/$FTL_SHORT_VERSION@g" be-engine.tra
fi

if [ ! -z "$ACTIVESPACES_SHORT_VERSION" ]
then
    mkdir -p /tibco_home/as/${ACTIVESPACES_SHORT_VERSION}
    cp -r /opt/tibco/as/${ACTIVESPACES_SHORT_VERSION}/lib /tibco_home/as/${ACTIVESPACES_SHORT_VERSION}
    sed -i "s@tibco.env.ACTIVESPACES_HOME=@tibco.env.ACTIVESPACES_HOME=/opt/tibco/as/$ACTIVESPACES_SHORT_VERSION@g" be-engine.tra
fi

if [ "$COMPONENT" != "rms" ]
then
    rm -rf /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/gwt
    rm -rf /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/tomsawyer
fi

if [ "$COMPONENT" = "rms" -o "$COMPONENT" = "$tea" ];
then
    rm -rf /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/aws
fi

rm -rf /opt/tibco/be/${BE_SHORT_VERSION}/lib/eclipse
rm -rf /home/tibco/be/be_installers-hf

cp -r /opt/tibco/tibcojre64/${JRE_VERSION} /tibco_home/tibcojre64

if [ "$COMPONENT" != "tea" ]
then
    cp /opt/tibco/be/${BE_SHORT_VERSION}/bin/be-engine /tibco_home/be/${BE_SHORT_VERSION}/bin
    cp /opt/tibco/be/${BE_SHORT_VERSION}/bin/be-engine.tra /tibco_home/be/${BE_SHORT_VERSION}/bin
    cp /opt/tibco/be/${BE_SHORT_VERSION}/bin/*.idx /tibco_home/be/${BE_SHORT_VERSION}/bin
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/lib /tibco_home/be/${BE_SHORT_VERSION}
    cp -r /opt/tibco/be/ext /tibco_home/be    
    if [ "$COMPONENT" = "rms" ]
    then
        cp -r /opt/tibco/be/${BE_SHORT_VERSION}/mm /tibco_home/be/${BE_SHORT_VERSION}
        cp -r /opt/tibco/be/${BE_SHORT_VERSION}/rms /tibco_home/be/${BE_SHORT_VERSION}
        mkdir -p /tibco_home/be/${BE_SHORT_VERSION}/examples/standard
        cp -r /opt/tibco/be/${BE_SHORT_VERSION}/examples/standard/WebStudio /tibco_home/be/${BE_SHORT_VERSION}/examples/standard
        cp -r /opt/tibco/be/${BE_SHORT_VERSION}/studio /tibco_home/be/${BE_SHORT_VERSION}
        cp -r /opt/tibco/be/${BE_SHORT_VERSION}/eclipse-platform /tibco_home/be/${BE_SHORT_VERSION}
        cp -r /opt/tibco/be/ext /tibco_home/be/${BE_SHORT_VERSION}/rms/bin/
    else
        mkdir -p /tibco_home/be/application/ear
        cp /tibco_home/be/ext/${CDD_FILE_NAME} /tibco_home/be/application/
        cp /tibco_home/be/ext/${EAR_FILE_NAME} /tibco_home/be/application/ear/
        rm -f /tibco_home/be/ext/${CDD_FILE_NAME}
        rm -f /tibco_home/be/ext/${EAR_FILE_NAME}
    fi
    rm -rf /home/tibco/be/*.py
    rm -rf /home/tibco/be/run_teagent.sh        
else
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/teagent /tibco_home/be/${BE_SHORT_VERSION}
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/lib/*.jar /tibco_home/be/${BE_SHORT_VERSION}/lib
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext /tibco_home/be/${BE_SHORT_VERSION}/lib
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/mm /tibco_home/be/${BE_SHORT_VERSION}
fi

rm -rf /home/tibco/be/logs
rm -rf /home/tibco/be/tomcat.log
