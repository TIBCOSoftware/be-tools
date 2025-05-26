#supported As versions for be version
AS_VERSION_MAP_MIN=( "6.0.0:4.4.0" "6.1.0:4.6.1" "6.1.1:4.6.1" "6.1.2:4.7.0" "6.2.0:4.7.0" "6.2.1:4.7.0" "6.2.2:4.7.0" "6.3.0:4.7.0" "6.3.1:4.7.0" "6.3.2:4.7.0" "6.4.0:4.7.0")
AS_VERSION_MAP_MAX=( "6.0.0:4.4.0" "6.1.0:4.6.1" "6.1.1:4.7.0" "6.1.2:4.7.0" "6.2.0:4.7.0" "6.2.1:4.7.0" "6.2.2:4.7.1" "6.3.0:4.8.1" "6.3.1:4.10.1" "6.3.2:5.0.0" "6.4.0:5.0.0")

asMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${AS_VERSION_MAP_MIN[@]}" ) | sed -e "s/x/9/g" )
asMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${AS_VERSION_MAP_MAX[@]}" ) | sed -e "s/x/9/g" )

asMinVersion=$(getNumberFromVersion $asMinVersion)
asMaxVersion=$(getNumberFromVersion $asMaxVersion)

asPkgRegex="TIB_as_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_linux_x86_64.zip"
asPkgHfRegex="TIB_as_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}(-|_)HF-[0-9][0-9][0-9]_linux_x86_64.zip"

validateInstallers "AS" "$asPkgRegex" "$asPkgHfRegex" "$asMinVersion" "$asMaxVersion"

ARG_AS_VERSION=$ARG_BASE_VERSION
ARG_AS_SHORT_VERSION=$ARG_BASE_SHORT_VERSION
ARG_AS_HOTFIX=$ARG_BASE_HOTFIX
