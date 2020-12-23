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
