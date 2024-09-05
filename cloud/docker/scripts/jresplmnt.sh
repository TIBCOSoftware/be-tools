#supported JRE Suppliment versions for be version
JRESPLMNT_VERSION_MAP_MIN=( "6.2.1:1.0.0" )
JRESPLMNT_VERSION_MAP_MAX=( "6.2.1:2.0.0" )

jresplmntMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${JRESPLMNT_VERSION_MAP_MIN[@]}" ) | sed -e "s/x/9/g" )
jresplmntMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${JRESPLMNT_VERSION_MAP_MAX[@]}" ) | sed -e "s/x/9/g" )

jresplmntMinVersion=$(getNumberFromVersion $jresplmntMinVersion)
jresplmntMaxVersion=$(getNumberFromVersion $jresplmntMaxVersion)

jresplmntPkgRegex="TIB_jresplmnt_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_HF-[0-9][0-9][0-9]_linux_x86_64.zip"
jresplmntPkgHfRegex="TIB_jresplmnt_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_HF-[0-9][0-9][0-9]_linux_x86_64.zip"

validateInstallers "JRESPLMNT" "$jresplmntPkgRegex" "$jresplmntPkgHfRegex" "$jresplmntMinVersion" "$jresplmntMaxVersion"

ARG_JRESPLMNT_VERSION=$ARG_BASE_VERSION
ARG_JRESPLMNT_SHORT_VERSION=$ARG_BASE_SHORT_VERSION
ARG_JRESPLMNT_HOTFIX=$ARG_BASE_HOTFIX
