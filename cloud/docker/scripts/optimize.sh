XPATH="provider/type"
CLUSTER_PROVIDER=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)

if [ "$CLUSTER_PROVIDER" = "AS2x" ]; then
    ARG_INCLUDE_MODULES=$(assignToList as2 $ARG_INCLUDE_MODULES )
elif [ "$CLUSTER_PROVIDER" = "Ignite" ]; then
    ARG_INCLUDE_MODULES=$(assignToList ignite $ARG_INCLUDE_MODULES )
elif [ "$CLUSTER_PROVIDER" = "FTL" ]; then
    ARG_INCLUDE_MODULES=$(assignToList ftl $ARG_INCLUDE_MODULES )
else
    ARG_INCLUDE_MODULES=$(assignToList inmem $ARG_INCLUDE_MODULES )
fi

XPATH="object-management/cache-manager/type"
OBJECT_MNGMNT=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)

if [ "$OBJECT_MNGMNT" = "AS2x" ]; then
    ARG_INCLUDE_MODULES=$(assignToList as2 $ARG_INCLUDE_MODULES )
elif [ "$OBJECT_MNGMNT" = "Ignite" ]; then
    ARG_INCLUDE_MODULES=$(assignToList ignite $ARG_INCLUDE_MODULES )
fi

XPATH="object-management/cache-manager/backing-store/persistence-option"
PERSISTANCE_OPT=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)

if [ "$PERSISTANCE_OPT" = "Store" ]; then
    XPATH="object-management/cache-manager/backing-store/type"
    BACKNG_STORE=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)

    if [ "$BACKNG_STORE" = "SQL Server" ]; then
        ARG_INCLUDE_MODULES=$(assignToList sqlserver $ARG_INCLUDE_MODULES )
    elif [ "$BACKNG_STORE" = "Cassandra" ]; then
        ARG_INCLUDE_MODULES=$(assignToList cassandra $ARG_INCLUDE_MODULES )
    elif [ "$BACKNG_STORE" = "ActiveSpaces" ]; then
        ARG_INCLUDE_MODULES=$(assignToList as4 $ARG_INCLUDE_MODULES )
    fi
fi

XPATH="object-management/store-manager/type"
INMEM_BACKNG_STORE=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
if [ "$INMEM_BACKNG_STORE" != "" ]; then
    if [ "$INMEM_BACKNG_STORE" = "Cassandra" ]; then
        ARG_INCLUDE_MODULES=$(assignToList cassandra $ARG_INCLUDE_MODULES )
    elif [ "$INMEM_BACKNG_STORE" = "ActiveSpaces" ]; then
        ARG_INCLUDE_MODULES=$(assignToList as4 $ARG_INCLUDE_MODULES )
    fi
fi

XPATH="app-metrics-config/store-provider/type"
METRICS=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
if [ "$METRICS" != "" ]; then
    if [ "$METRICS" = "LDM" ]; then
        ARG_INCLUDE_MODULES=$(assignToList liveview $ARG_INCLUDE_MODULES )
    elif [ "$METRICS" = "InfluxDB" ]; then
        ARG_INCLUDE_MODULES=$(assignToList influx $ARG_INCLUDE_MODULES )
    fi
fi

XPATH="telemetry-config/span-exporter/type"
TELEMETRY=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
if [ "$TELEMETRY" != "" -a "$TELEMETRY" != "always_off" ]; then
    ARG_INCLUDE_MODULES=$(assignToList opentelemetry $ARG_INCLUDE_MODULES )
fi
