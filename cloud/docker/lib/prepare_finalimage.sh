if [ "$OPEN_JDK_FILENAME" != "na" -a "$OPEN_JDK_FILENAME" != "" ]; then
    mkdir -p /opt/tibco/openjdk/$JRE_VERSION
    tar xvf /home/tibco/be/$OPEN_JDK_FILENAME --directory /opt/tibco 1>/dev/null
    rm -rf /home/tibco/be/$OPEN_JDK_FILENAME
    mv /opt/tibco/jd*/* /opt/tibco/openjdk/$JRE_VERSION/

    find /opt/tibco -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~tibcojre64~openjdk~g"
fi

DEL_LIST_FILENAME="/home/tibco/be/deletelist.txt"
cd /opt/tibco/be/$BE_SHORT_VERSION/bin/
if [ "$COMPONENT" = "rms" ]; then
    DEL_LIST_FILENAME="/home/tibco/be/deletelistrms.txt"
    TRA_FILE="../rms/bin/be-rms.tra"
elif [ "$COMPONENT" = "tea" ]; then
    TRA_FILE="../teagent/bin/be-teagent.tra"
else
    TRA_FILE="be-engine.tra"
fi

if [ -e "$DEL_LIST_FILENAME" ]; then
    sed -i 's/\r$//' $DEL_LIST_FILENAME
    for filename in $(cat "$DEL_LIST_FILENAME" ) ; do
        rm -rf $filename 2>/dev/null
    done
fi

if [ "$COMPONENT" != "tea" ]; then
    echo "java.property.be.engine.cluster.as.discover.url=%AS_DISCOVER_URL%" >> $TRA_FILE
    echo "java.property.be.engine.cluster.as.listen.url=%AS_LISTEN_URL%" >> $TRA_FILE
    echo "java.property.be.engine.cluster.as.remote.listen.url=%AS_REMOTE_LISTEN_URL%" >> $TRA_FILE
fi

echo "java.property.com.sun.management.jmxremote.rmi.port=%jmx_port%" >> $TRA_FILE

mkdir -p /tibco_home/be/${BE_SHORT_VERSION}/bin

if [ "$AS_SHORT_VERSION" != "" -a "$AS_SHORT_VERSION" != "na" ]; then 
    mkdir -p /tibco_home/as/${AS_SHORT_VERSION}
    cp -r /opt/tibco/as/${AS_SHORT_VERSION}/lib /tibco_home/as/${AS_SHORT_VERSION}
fi

if [ "$FTL_SHORT_VERSION" != "" -a "$FTL_SHORT_VERSION" != "na" ]; then 
    mkdir -p /tibco_home/ftl/${FTL_SHORT_VERSION}
    rm -r /opt/tibco/ftl/${FTL_SHORT_VERSION}/lib/simplejson
    cp -r /opt/tibco/ftl/${FTL_SHORT_VERSION}/lib /tibco_home/ftl/${FTL_SHORT_VERSION}
    sed -i "s@tibco.env.FTL_HOME=@tibco.env.FTL_HOME=/opt/tibco/ftl/$FTL_SHORT_VERSION@g" $TRA_FILE
fi

if [ "$ACTIVESPACES_SHORT_VERSION" != "" -a "$ACTIVESPACES_SHORT_VERSION" != "na" ]; then
    mkdir -p /tibco_home/as/${ACTIVESPACES_SHORT_VERSION}
    cp -r /opt/tibco/as/${ACTIVESPACES_SHORT_VERSION}/lib /tibco_home/as/${ACTIVESPACES_SHORT_VERSION}
    sed -i "s@tibco.env.ACTIVESPACES_HOME=@tibco.env.ACTIVESPACES_HOME=/opt/tibco/as/$ACTIVESPACES_SHORT_VERSION@g" $TRA_FILE
fi

if [ "$HAWK_SHORT_VERSION" != "" -a "$HAWK_SHORT_VERSION" != "na" ]; then 
    mkdir -p /tibco_home/hawk/${HAWK_SHORT_VERSION}
    cp -r /opt/tibco/hawk/${HAWK_SHORT_VERSION}/lib /tibco_home/hawk/${HAWK_SHORT_VERSION}
    sed -i "s@tibco.env.HAWK_HOME=@tibco.env.HAWK_HOME=/opt/tibco/hawk/$HAWK_SHORT_VERSION@g" $TRA_FILE
fi

if [ "$TEA_VERSION" != "" -a "$TEA_VERSION" != "na" ]; then 
    mkdir -p /tibco_home/tea/${TEA_VERSION}
    cp -r /opt/tibco/tea/${TEA_VERSION}/agentlib /tibco_home/tea/${TEA_VERSION}
    sed -i "s@tibco.env.TEA_HOME=@tibco.env.TEA_HOME=/opt/tibco/tea/$TEA_VERSION@g" $TRA_FILE
fi

if [ "$COMPONENT" != "rms" ]; then
    rm -rf /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/gwt
    find /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/tomsawyer -type f -not -name 'xml*' -delete 2>/dev/null
fi

if [ "$COMPONENT" = "rms" -o "$COMPONENT" = "tea" ]; then
    find /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/aws -type f -not -name 'guava*' -delete 2>/dev/null
fi

find /opt/tibco/be/${BE_SHORT_VERSION}/lib/eclipse/plugins -type f -not -name '*bpmn*' -delete 2>/dev/null
rm -rf /home/tibco/be/be_installers-hf

if [ "$OPEN_JDK_FILENAME" != "na" -a "$OPEN_JDK_FILENAME" != "" ]; then
    cp -r /opt/tibco/openjdk /tibco_home
else
    cp -r /opt/tibco/tibcojre64 /tibco_home
fi

if [ "$COMPONENT" != "tea" ]; then
    cp be-engine be-engine.tra /tibco_home/be/${BE_SHORT_VERSION}/bin
    if [ -e cassandrakeywordmap.xml ]; then
        cp cassandrakeywordmap.xml /tibco_home/be/${BE_SHORT_VERSION}/bin
    fi
    if [ -e *.idx ]; then
        cp *.idx /tibco_home/be/${BE_SHORT_VERSION}/bin
    fi
    if [ -e dbkeywordmap.xml ]; then
        cp dbkeywordmap.xml /tibco_home/be/${BE_SHORT_VERSION}/bin
    fi
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/lib /tibco_home/be/${BE_SHORT_VERSION}
    cp -r /opt/tibco/be/ext /tibco_home/be    

    if [ "$COMPONENT" = "rms" ]; then
        [ -d "../eclipse-platform" ] && cp -r ../eclipse-platform /tibco_home/be/${BE_SHORT_VERSION}
        cp -r ../mm ../rms ../studio /tibco_home/be/${BE_SHORT_VERSION}
        rm -f /tibco_home/be/${BE_SHORT_VERSION}/rms/bin/be-rms.tra.1
        rm -f /tibco_home/be/${BE_SHORT_VERSION}/rms/bin/be-rms.tra.2
        mkdir -p /tibco_home/be/${BE_SHORT_VERSION}/examples/standard
        cp -r ../examples/standard/WebStudio /tibco_home/be/${BE_SHORT_VERSION}/examples/standard
        mv -f /opt/tibco/be/ext/*.cdd /opt/tibco/be/ext/*.ear /opt/tibco/be/ext/*.war /opt/tibco/be/ext/*.tra /tibco_home/be/${BE_SHORT_VERSION}/rms/bin/ 2>/dev/null
        mv -f /opt/tibco/be/${BE_SHORT_VERSION}/pom.xml /tibco_home/be/${BE_SHORT_VERSION}/ 2>/dev/null
        mv -f /opt/tibco/be/${BE_SHORT_VERSION}/examples/pom.xml /tibco_home/be/${BE_SHORT_VERSION}/examples/ 2>/dev/null
    else
        mkdir -p /tibco_home/be/application/ear
        cp /tibco_home/be/ext/${CDD_FILE_NAME} /tibco_home/be/application/
        cp /tibco_home/be/ext/${EAR_FILE_NAME} /tibco_home/be/application/ear/
        rm -f /tibco_home/be/ext/${CDD_FILE_NAME} /tibco_home/be/ext/${EAR_FILE_NAME}
    fi

    rm -rf /home/tibco/be/*.py /home/tibco/be/run_teagent.sh        
else
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/teagent /tibco_home/be/${BE_SHORT_VERSION}
    mkdir -p /tibco_home/be/${BE_SHORT_VERSION}/lib
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/lib/*.jar /tibco_home/be/${BE_SHORT_VERSION}/lib
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext /tibco_home/be/${BE_SHORT_VERSION}/lib
    cp -r /opt/tibco/be/${BE_SHORT_VERSION}/mm /tibco_home/be/${BE_SHORT_VERSION}
fi

rm -rf /home/tibco/be/logs
rm -rf /home/tibco/be/tomcat.log
