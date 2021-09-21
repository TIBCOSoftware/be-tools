XPATH="provider/type"
CLUSTER_PROVIDER=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)

if [ "$CLUSTER_PROVIDER" = "AS2x" ]; then
    INCLUDE_MODULES=$(assignToList as2 $INCLUDE_MODULES )
elif [ "$CLUSTER_PROVIDER" = "Ignite" ]; then
    INCLUDE_MODULES=$(assignToList ignite $INCLUDE_MODULES )
elif [ "$CLUSTER_PROVIDER" = "FTL" ]; then
    INCLUDE_MODULES=$(assignToList ftl $INCLUDE_MODULES )
else
    INCLUDE_MODULES=$(assignToList inmem $INCLUDE_MODULES )
fi

XPATH="object-management/cache-manager/type"
OBJECT_MNGMNT=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)

if [ "$OBJECT_MNGMNT" = "AS2x" ]; then
    INCLUDE_MODULES=$(assignToList as2 $INCLUDE_MODULES )
elif [ "$OBJECT_MNGMNT" = "Ignite" ]; then
    INCLUDE_MODULES=$(assignToList ignite $INCLUDE_MODULES )
fi

XPATH="object-management/cache-manager/backing-store/persistence-option"
PERSISTANCE_OPT=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)

if [ "$PERSISTANCE_OPT" = "Store" ]; then
    XPATH="object-management/cache-manager/backing-store/type"
    BACKNG_STORE=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
    INCLUDE_MODULES=$(assignToList store $INCLUDE_MODULES )
    if [ "$BACKNG_STORE" = "SQL Server" ]; then
        INCLUDE_MODULES=$(assignToList sqlserver $INCLUDE_MODULES )
    elif [ "$BACKNG_STORE" = "Cassandra" ]; then
        INCLUDE_MODULES=$(assignToList cassandra $INCLUDE_MODULES )
    elif [ "$BACKNG_STORE" = "ActiveSpaces" ]; then
        INCLUDE_MODULES=$(assignToList as4 $INCLUDE_MODULES )
    fi
fi

XPATH="object-management/store-manager/type"
INMEM_BACKNG_STORE=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
if [ "$INMEM_BACKNG_STORE" != "" ]; then
    INCLUDE_MODULES=$(assignToList store $INCLUDE_MODULES )
    if [ "$INMEM_BACKNG_STORE" = "Cassandra" ]; then
        INCLUDE_MODULES=$(assignToList cassandra $INCLUDE_MODULES )
    elif [ "$INMEM_BACKNG_STORE" = "ActiveSpaces" ]; then
        INCLUDE_MODULES=$(assignToList as4 $INCLUDE_MODULES )
    fi
fi

XPATH="app-metrics-config/store-provider/type"
METRICS=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
if [ "$METRICS" != "" ]; then
    if [ "$METRICS" = "LDM" ]; then
        INCLUDE_MODULES=$(assignToList liveview $INCLUDE_MODULES )
    elif [ "$METRICS" = "InfluxDB" ]; then
        INCLUDE_MODULES=$(assignToList influx $INCLUDE_MODULES )
    fi
fi

XPATH="telemetry-config/sampler"
TELEMETRY=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
if [ "$TELEMETRY" != "" -a "$TELEMETRY" != "always_off" ]; then
    INCLUDE_MODULES=$(assignToList opentelemetry $INCLUDE_MODULES )
fi
