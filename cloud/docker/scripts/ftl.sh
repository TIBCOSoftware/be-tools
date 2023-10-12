#supported FTL versions for be version
FTL_VERSION_MAP_MIN=( "6.0.0:6.4.0" "6.1.0:6.5.0" "6.1.1:6.5.0" "6.1.2:6.7.1" "6.2.0:6.7.1" "6.2.1:6.7.1" "6.2.2:6.7.1" "6.3.0:6.7.1" )
FTL_VERSION_MAP_MAX=( "6.0.0:6.4.x" "6.1.0:6.5.0" "6.1.1:6.6.1" "6.1.2:6.7.1" "6.2.0:6.7.1" "6.2.1:6.7.1" "6.2.2:6.7.3" "6.3.0:6.10.0" )

ftlMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${FTL_VERSION_MAP_MIN[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )
ftlMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${FTL_VERSION_MAP_MAX[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

ftlPkgRegex="TIB_ftl_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_linux_x86_64.zip"
ftlPkgHfRegex="TIB_ftl_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}(-|_)HF-[0-9][0-9][0-9]_linux_x86_64.zip"

validateInstallers "FTL" "$ftlPkgRegex" "$ftlPkgHfRegex" "$ftlMinVersion" "$ftlMaxVersion"

ARG_FTL_VERSION=$ARG_BASE_VERSION
ARG_FTL_SHORT_VERSION=$ARG_BASE_SHORT_VERSION
ARG_FTL_HOTFIX=$ARG_BASE_HOTFIX
