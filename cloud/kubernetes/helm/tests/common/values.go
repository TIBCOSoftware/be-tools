package common

const (
	imageName                      = "s2ifd:01"
	beServicePort            int32 = 8108
	beCacheServicePort       int32 = 50000
	beJmxServicePort         int32 = 5555
	as4GridNameKey                 = "grid_name"
	as4GridNameVal                 = "fd_store"
	cassandraKeyspaceNameKey       = "cass_keyspace_name"
	cassandraKeyspaceNameVal       = "testDb"
	ftlServerURLKey                = "FTL_gv_REALM_SERVER"
	ftlServerURLVal                = "sampleftlurl"
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
	Values["as4configmap."+as4GridNameKey] = as4GridNameVal
	return Values
}

// InmemoryCassandraStoreValues returns Inmemory store topology values
func InmemoryCassandraStoreValues() map[string]string {
	Values["omType"] = "store"
	Values["storeType"] = "Cassandra"
	Values["cassconfigmap."+cassandraKeyspaceNameKey] = cassandraKeyspaceNameVal
	return Values
}

// FTLAS4StoreValues returns cluster ftl store topology values
func FTLAS4StoreValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "store"
	Values["storeType"] = "AS4"
	Values["as4configmap."+as4GridNameKey] = as4GridNameVal
	Values["ftl."+ftlServerURLKey] = ftlServerURLVal

	return Values
}

// FTLCassandraStoreValues returns cluster ftl store topology values
func FTLCassandraStoreValues() map[string]string {
	Values["cmType"] = "FTL"
	Values["omType"] = "store"
	Values["storeType"] = "Cassandra"
	Values["cassconfigmap."+cassandraKeyspaceNameKey] = cassandraKeyspaceNameVal
	Values["ftl."+ftlServerURLKey] = ftlServerURLVal

	return Values
}

// AS2CacheNoneValues returns cluster as2 cache none
func AS2CacheNoneValues() map[string]string {
	Values["cmType"] = "AS2"
	Values["omType"] = "cache"
	Values["bsType"] = "None"

	return Values
}
