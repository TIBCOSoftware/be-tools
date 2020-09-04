//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package common

// HelmChartPath path to helm chart
var HelmChartPath = "../../helm"

// Beappservice template file name
var Beappservice = "templates/beservice.yaml"

// Bejmx template file name
var Bejmx = "templates/bejmx-service.yaml"

// Beinferenceagent template file name
var Beinferenceagent = "templates/beinferenceagent.yaml"

// Configmap template file name
var Configmap = "templates/configmap.yaml"

// Becacheagent template file name
var Becacheagent = "templates/becacheagent.yaml"

// Becacheservice template file name
var Becacheservice = "templates/becache-service.yaml"

// ReleaseName is release name for BE App
var ReleaseName = Values["cpType"] + "-" + "beapp"

const (
	imageName                      = "s2ifd:01"
	beServicePort            int32 = 8108
	beAS2CacheServicePort    int32 = 50000
	beIgniteCacheServicePort int32 = 47500
	beJmxServicePort         int32 = 5555
	infServicePortType             = "NodePort"
	jmxServicePortType             = "LoadBalancer"

	infReplicas     int32 = 1
	cacheReplicas   int32 = 1
	imagePullPolicy       = "IfNotPresent"

	accessMode    = "ReadWriteOnce"
	snmountVolume = "store"
	snpath        = "/mnt/tibco/be/data-store"
	storageClass  = "standard"
	defaultPU     = "default"
	cachePU       = "cache"
	igniteURL     = "IGNITE_DISCOVER_URL"
	asURL         = "AS_DISCOVER_URL"
	// as4 constants
	as4ReamURLKey    = "realm_url"
	as4ReamURLVal    = "localhost"
	as4SecReamURLKey = "sec_realm_url"
	as4SecReamURLVal = "localhost"
	as4GridNameKey   = "grid_name"
	as4GridNameVal   = "fd_store"

	// cassandra constants
	cassandraSerHostNameKey  = "cass_server"
	cassandraSerHostNameVal  = "localhost:9042"
	cassandraUserNameKey     = "cass_username"
	cassandraUserNameVal     = "cassusername"
	cassandraPasswKey        = "cass_password"
	cassandraPasswVal        = "casspassw"
	cassandraKeyspaceNameKey = "cass_keyspace_name"
	cassandraKeyspaceNameVal = "testDb"

	// rdbms database constants
	rdbmsDriverKey     = "dbdriver"
	rdbmsDriverVal     = "com.mysql.jdbc.Driver"
	rdbmsDbUsernameKey = "dbusername"
	rdbmsDbUsernameVal = "mysqldb"
	rdbmsDbPswdKey     = "dbpwd"
	rdbmsDbPswdVal     = "mysqldbpwd"

	// FTL constants
	ftlServerURLKey   = "FTL_gv_REALM_SERVER"
	ftlServerURLVal   = "sampleftlurl"
	ftlClusterNameKey = "FTL_gv_CLUSTER_NAME"
	ftlClusterNameVal = "samplecluster"
)

// Values is complete default set of values.yaml
var Values = map[string]string{
	"cpType":          "minikube",
	"cmType":          "unclustered",
	"omType":          "inmemory",
	"image":           imageName,
	"imagePullPolicy": "IfNotPresent",
}

// InmemoryValues returns Inmemory topology values
func InmemoryValues() map[string]string {
	return Values
}

// InmemoryAS4StoreValues returns Inmemory store topology values
func InmemoryAS4StoreValues() map[string]string {
	Values["omType"] = "store"
	Values["storeType"] = "AS4"
	Values = appendAs4Values(Values)
	return Values
}

// InmemoryCassandraStoreValues returns Inmemory store topology values
func InmemoryCassandraStoreValues() map[string]string {
	Values["omType"] = "store"
	Values["storeType"] = "Cassandra"
	Values = appendCassandraValues(Values)
	return Values
}

// FTLAS4StoreValues returns cluster ftl store topology values
func FTLAS4StoreValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "store"
	Values["storeType"] = "AS4"
	Values = appendAs4Values(Values)
	Values = appendFTLValues(Values)

	return Values
}

// FTLCassandraStoreValues returns cluster ftl store topology values
func FTLCassandraStoreValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "store"
	Values["storeType"] = "Cassandra"
	Values = appendCassandraValues(Values)
	Values = appendFTLValues(Values)

	return Values
}

// AS2CacheNoneValues returns cluster as2 cache none
func AS2CacheNoneValues() map[string]string {
	Values["cmType"] = "AS2"
	Values["omType"] = "cache"
	Values["bsType"] = "None"

	return Values
}

// AS2CacheSNValues returns cluster as2 cache none
func AS2CacheSNValues() map[string]string {
	Values["cmType"] = "AS2"
	Values["omType"] = "cache"
	Values["bsType"] = "sharedNothing"

	return Values
}

// FTLCacheNoneValues returns cluster ftl cache none
func FTLCacheNoneValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "cache"
	Values["bsType"] = "None"
	Values = appendFTLValues(Values)

	return Values
}

// FTLCacheSNValues returns cluster ftl cache none
func FTLCacheSNValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "cache"
	Values["bsType"] = "sharedNothing"
	Values = appendFTLValues(Values)

	return Values
}

// FTLCacheAS4StoreValues returns cluster ftl store topology values
func FTLCacheAS4StoreValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "cache"
	Values["storeType"] = "AS4"
	Values["bsType"] = "store"
	Values = appendAs4Values(Values)
	Values = appendFTLValues(Values)

	return Values
}

// FTLCacheCassandraStoreValues returns cluster ftl store topology values
func FTLCacheCassandraStoreValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "cache"
	Values["storeType"] = "Cassandra"
	Values["bsType"] = "store"
	Values = appendCassandraValues(Values)
	Values = appendFTLValues(Values)

	return Values
}

// AS2CacheRDBMSStoreValues returns cluster as2 cache none
func AS2CacheRDBMSStoreValues() map[string]string {
	Values["cmType"] = "AS2"
	Values["omType"] = "cache"
	Values["storeType"] = "RDBMS"
	Values["bsType"] = "store"
	Values = appendMysqlValues(Values)

	return Values
}

// FTLCacheMysqlStoreValues returns cluster ftl store topology values
func FTLCacheMysqlStoreValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "cache"
	Values["storeType"] = "RDBMS"
	Values["bsType"] = "store"
	Values = appendMysqlValues(Values)
	Values = appendFTLValues(Values)

	return Values
}

func appendCassandraValues(data map[string]string) map[string]string {
	data["cassconfigmap."+cassandraSerHostNameKey] = cassandraSerHostNameVal
	data["cassconfigmap."+cassandraKeyspaceNameKey] = cassandraKeyspaceNameVal
	data["cassconfigmap."+cassandraUserNameKey] = cassandraUserNameVal
	data["cassconfigmap."+cassandraPasswKey] = cassandraPasswVal

	return data
}

func appendAs4Values(data map[string]string) map[string]string {
	data["as4configmap."+as4ReamURLKey] = as4ReamURLVal
	data["as4configmap."+as4SecReamURLKey] = as4SecReamURLVal
	data["as4configmap."+as4GridNameKey] = as4GridNameVal

	return data
}

func appendMysqlValues(data map[string]string) map[string]string {
	data["mysql.enabled"] = "true"
	data["configmap."+rdbmsDriverKey] = rdbmsDriverVal
	data["configmap."+rdbmsDbPswdKey] = rdbmsDbPswdVal
	data["configmap."+rdbmsDbUsernameKey] = rdbmsDbUsernameVal

	return data
}

func appendFTLValues(data map[string]string) map[string]string {
	data["ftl."+ftlServerURLKey] = ftlServerURLVal
	data["ftl."+ftlClusterNameKey] = ftlClusterNameVal

	return data
}
