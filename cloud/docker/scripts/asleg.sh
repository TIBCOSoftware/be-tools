#supported Activespaces(legacy) versions for be version
AS_LEG_VERSION_MAP_MIN=( "5.6.0:2.3.0" "5.6.1:2.3.0" "6.0.0:2.4.0" "6.1.0:2.4.0" "6.1.1:2.4.0" "6.1.2:2.4.1" "6.2.0:2.4.0" "6.2.1:2.4.1" "6.2.2:2.4.1" "6.3.0:2.4.1" "6.3.1:2.4.1" )
AS_LEG_VERSION_MAP_MAX=( "5.6.0:2.4.0" "5.6.1:2.4.1" "6.0.0:2.4.1" "6.1.0:2.4.1" "6.1.1:2.4.1" "6.1.2:2.4.1" "6.2.0:2.4.1" "6.2.1:2.4.1" "6.2.2:2.4.2" "6.3.0:2.4.2" "6.3.1:2.4.2" )

asLegMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${AS_LEG_VERSION_MAP_MIN[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )
asLegMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${AS_LEG_VERSION_MAP_MAX[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

asLegPkgRegex="TIB_activespaces_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_linux_x86_64.zip"
asLegPkgHfRegex="TIB_activespaces_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}(-|_)HF-[0-9][0-9][0-9]_linux_x86_64.zip"

validateInstallers "Activespaces(legacy)" "$asLegPkgRegex" "$asLegPkgHfRegex" "$asLegMinVersion" "$asLegMaxVersion"

ARG_AS_LEG_VERSION=$ARG_BASE_VERSION
ARG_AS_LEG_SHORT_VERSION=$ARG_BASE_SHORT_VERSION
ARG_AS_LEG_HOTFIX=$ARG_BASE_HOTFIX
