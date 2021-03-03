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