
DOT="\."

getFromArray()
{
    key=$1
    shift;
    array=("$@")
    for loopVal in "${array[@]}" ; do
        loopKey="${loopVal%%:*}"
        if [ $loopKey = $key ]; then
            result="${loopVal##*:}"
        fi
    done
    echo $result
}

RemoveDuplicatesAndFormatCPs()
{
    result=""
    oIFS="$IFS"; IFS=','; declare -a values=($1);

    for key in "${values[@]}"; do

        if ! [ "$key" = "gvhttp" -o "$key" = "gvconsul" -o "$key" = "gvcyberark" -o "$key" = "cmcncf" ]; then
            key=${key/custom\//}
            key=${key/custom\\/}
            key="custom/$key"
        fi

        if [ "$result" = "" ]; then
            result="$key"
        else
            DUPLICATE_FOUND="false"
            declare -a values2=($result)
            for key2 in "${values2[@]}"; do
                if [ "$key2" == "$key" ]; then
                    DUPLICATE_FOUND="true"
                fi
            done
            if [ "$DUPLICATE_FOUND" == "false" -a "$key" != "" ]; then
                result="$result,$key"
            fi
        fi
    done
    IFS="$oIFS"; unset oIFS
    echo $result
}

validateFTLandAS()
{
    ARG_BE_VERSION=$1
    IMAGE_NAME=$2
    RMS_IMAGE=$3
    VALIDATE_FTL_AS="false"

    # check for FTL and AS4 only when BE version is > 6.0.0
    if [ $(echo "${ARG_BE_VERSION//.}") -ge 600 ]; then
        VALIDATE_FTL_AS="true"
    fi

    # check for FTL and AS4 only when BE version is > 6.1.1 if app is rms
    if [ "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
        if [ $(echo "${ARG_BE_VERSION//.}") -ge 611 ]; then
            VALIDATE_FTL_AS="true"
        else
            VALIDATE_FTL_AS="false"
        fi
    fi

    echo $VALIDATE_FTL_AS
}

validateInstallers()
{
    pkgName=$1
    basePckgRegex=$2
    basePckgHfRegex=$3
    baseMinVersion=$4
    baseMaxVersion=$5

    ARG_BASE_VERSION="na"
    ARG_BASE_SHORT_VERSION="na"
    ARG_BASE_HOTFIX="na"

    # Validate and get TIBCO $pkgName base and hf versions
    basePckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 | grep -E "$basePckgRegex"  )
    basePckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 | grep -E "$basePckgRegex"  |  wc -l)
    baseHfPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 | grep -E "$basePckgHfRegex"  )
    baseHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 | grep -E "$basePckgHfRegex"  |  wc -l)

    if [ $basePckgsCnt -gt 0 ]; then
        if [ $basePckgsCnt -gt 1 ]; then # If more than one $pkgName versions are present
            printf "\nERROR: More than one TIBCO $pkgName base versions are present in the target directory. There should be only one.\n"
            exit 1;
        elif [ $baseHfPckgsCnt -gt 1 ]; then
            printf "\nERROR: More than one TIBCO $pkgName HF are present in the target directory. There should be only one.\n"
            exit 1;
        elif [ $basePckgsCnt -eq 1 ]; then
            BASE_PACKAGE="$(basename ${basePckgs[0]} )"
            ARG_BASE_VERSION=$(echo $BASE_PACKAGE | cut -d'_' -f 3)

            # validate $pkgName version
            if [[ $ARG_BASE_VERSION =~ $VERSION_REGEX ]]; then
                ARG_BASE_SHORT_VERSION=${BASH_REMATCH[1]};
            else
                printf "ERROR: Improper $pkgName version: [$ARG_BASE_VERSION]. It should be in (x.x.x) format Ex: (6.2.0).\n"
                exit 1
            fi

            if [ "$baseMinVersion" != "" ]; then
                # validate $pkgName version with be base version
                baseVersion=$(echo "${ARG_BASE_VERSION}" | sed -e "s/${DOT}/${BLANK}/g" )
                
                if ! [[ (( $baseMinVersion -le $baseVersion )) && (( $baseVersion -le $baseMaxVersion )) ]]; then
                    printf "ERROR: BE version: [$ARG_BE_VERSION] not compatible with $pkgName version: [$ARG_BASE_VERSION].\n";
                    exit 1
                fi
            fi

            #add $pkgName package to file list and increment index
            FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$BASE_PACKAGE"
            FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

            if [ $baseHfPckgsCnt -eq 1 ]; then
                BASE_HF_PACKAGE="$(basename ${baseHfPckgs[0]})"
                baseHfBaseVersion=$(echo $BASE_HF_PACKAGE | cut -d'_' -f 3 | cut -d'-' -f 1)
                if [ "$ARG_BASE_VERSION" = "$baseHfBaseVersion" ]; then
                    if [[ $BASE_HF_PACKAGE =~ $HF_VERSION_REGEX ]]; then
                        ARG_BASE_HOTFIX=${BASH_REMATCH[0]}
                    else
                        printf "ERROR: Improper $pkgName HF version: [$BASE_HF_PACKAGE]. It should be in (xxx) format Ex: (002).\n"
                        exit 1
                    fi
                    if [ "$pkgName" != "JRESPLMNT" ] ; then
                        #add $pkgName hf package to file list and increment index
                        FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$BASE_HF_PACKAGE"
                        FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
                    fi
                else
                    printf "\nERROR: TIBCO $pkgName version: [$baseHfBaseVersion] in HF installer and TIBCO $pkgName Base version: [$ARG_BASE_VERSION] is not matching.\n"
                    exit 1;
                fi
            fi
        fi
    fi
}