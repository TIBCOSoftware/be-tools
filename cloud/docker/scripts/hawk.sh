#supported HAWK versions for be version
HAWK_VERSION_MAP_MIN=( "6.2.2:7.1.0" "6.3.0:7.1.0" )
HAWK_VERSION_MAP_MAX=( "6.2.2:7.1.0" "6.3.0:7.2.1" )

hawkMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${HAWK_VERSION_MAP_MIN[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )
hawkMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${HAWK_VERSION_MAP_MAX[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

hawkPkgRegex="TIB_oihr_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_linux_x86_64.zip"
hawkPkgHfRegex="TIB_oihr_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_HF-[0-9][0-9][0-9]_linux_x86_64.zip"

validateInstallers "HAWK" "$hawkPkgRegex" "$hawkPkgHfRegex" "$hawkMinVersion" "$hawkMaxVersion"

ARG_HAWK_VERSION=$ARG_BASE_VERSION
ARG_HAWK_SHORT_VERSION=$ARG_BASE_SHORT_VERSION
ARG_HAWK_HOTFIX=$ARG_BASE_HOTFIX
