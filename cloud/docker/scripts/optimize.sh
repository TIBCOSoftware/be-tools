XPATH="provider/type"
CLUSTER_PROVIDER=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
echo "CLUSTER_PROVIDER:[$CLUSTER_PROVIDER]"

XPATH="object-management/cache-manager/type"
OBJECT_MNGMNT=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
echo "OBJECT_MNGMNT:[$OBJECT_MNGMNT]"

XPATH="object-management/cache-manager/backing-store/persistence-option"
PERSISTANCE_OPT=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
echo "PERSISTANCE_OPT:[$PERSISTANCE_OPT]"

XPATH="object-management/cache-manager/backing-store/type"
BACKNG_STORE=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
echo "BACKNG_STORE:[$BACKNG_STORE]"

XPATH="object-management/store-manager/type"
INMEM_BACKNG_STORE=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
echo "INMEM_BACKNG_STORE:[$INMEM_BACKNG_STORE]"

XPATH="app-metrics-config/store-provider/type"
METRICS=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
echo "METRICS:[$METRICS]"

# XPATH="agent-classes/inference-agent-class/destinations/ref"
# CHANNEL=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
# echo "CHANNEL:[$CHANNEL]"

# if [ "$CHANNEL" != "" ]; then
#     XPATH="string(//cluster/destination-groups/destinations/"
#     CHANNEL=$(getXpathValueFrom $ARG_APP_LOCATION/$CDD_FILE_NAME $XPATH)
#     echo "CHANNEL:[$CHANNEL]"
# fi

# exit 1

## TO DO 
## Retrieve module names based on cdd content
## add them to ARG_INCLUDE_MODULES variable if present