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

removeDuplicatesAndFormatGVs()
{
    result=""
    oIFS="$IFS"; IFS=','; declare -a values=($1);

    for key in "${values[@]}"; do

        if ! [ "$key" = "http" -o "$key" = "consul" ]; then
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