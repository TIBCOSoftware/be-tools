#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

#!/bin/bash

function cassandradb(){
    cassandrapod=$(kubectl get pods -o name | grep cassandra)
    echo ${cassandrapod}
    cassandrapod=${cassandrapod:4}
    kubectl cp ../utils/cassandra.cql ${cassandrapod}:/opt/cassandra.cql
    kubectl exec -it ${cassandrapod} -- cqlsh localhost 9042 -u admin -p password -f /opt/cassandra.cql
}

function mysql(){
    mysqlpod=$(kubectl get pods -o name | grep mysql)
    echo ${mysqlpod}
    echo "kubectl exec -it ${mysqlpod} bash -c ./test.sh"
    # set -e
    kubectl exec -it ${mysqlpod} --  mysql -u root -ppassword < ../utils/mysql.sql
}

set +e
inputArgs=$1

if [[ $inputArgs == "cassandra" ]]; then
    cassandradb
elif [[ $inputArgs == "mysql" ]]; then
    mysql    
fi

set -e
EXIT_CODE=0
command || EXIT_CODE=$?