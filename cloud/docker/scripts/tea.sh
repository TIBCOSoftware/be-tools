#supported TEA versions for be version
TEA_VERSION_MAP_MIN=( "6.3.0:2.4.1" )
TEA_VERSION_MAP_MAX=( "6.3.0:2.4.1" )

teaMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${TEA_VERSION_MAP_MIN[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )
teaMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${TEA_VERSION_MAP_MAX[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

teaPkgRegex="TIB_tea_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_linux26gl23_x86_64.zip"
teaPkgHfRegex="TIB_tea_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}_HF-[0-9][0-9][0-9].zip"

validateInstallers "TEA" "$teaPkgRegex" "$teaPkgHfRegex" "$teaMinVersion" "$teaMaxVersion"

ARG_TEA_VERSION=$ARG_BASE_VERSION
ARG_TEA_SHORT_VERSION=$ARG_BASE_SHORT_VERSION
ARG_TEA_HOTFIX=$ARG_BASE_HOTFIX
