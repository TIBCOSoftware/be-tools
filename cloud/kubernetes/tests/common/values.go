//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package common

var ReleaseName = Values["cpType"] + "-" + "beapp"
var BeserviceName = ReleaseName + "-" + "beservice"
var InferenceSelectorName = ReleaseName + "-" + "beinferenceagent"
var JMXserviceName = ReleaseName + "-" + "jmx-service"
var CacheserviceName = ReleaseName + "-" + "becache-service"
var CacheSelectorName = ReleaseName + "-" + "becacheagent"
var ConfigmapName = ReleaseName + "-" + "storeconfig"
var SecretName = ReleaseName + "-" + "beimagepullsecret"

const (
	HelmChartPath                  = "../../helm"
	Bejmx                          = "templates/bejmx-service.yaml"
	Beappservice                   = "templates/beservice.yaml"
	Beinferenceagent               = "templates/beinferenceagent.yaml"
	Configmap                      = "templates/configmap.yaml"
	Becacheagent                   = "templates/becacheagent.yaml"
	Becacheservice                 = "templates/becache-service.yaml"
	SecretFile                     = "templates/imagepullsecret.yaml"
	FTLPATH                        = "../utils/ftl4be.yml"
	AS4PATH                        = "../utils/asdg.yml"
	SecretType                     = "kubernetes.io/dockerconfigjson"
	ImgPullSecret                  = "besecret"
	ImageName                      = "s2ifd:01"
	BeServicePort            int32 = 8108
	BeAS2CacheServicePort    int32 = 50000
	BeIgniteCacheServicePort int32 = 47500
	BeJmxServicePort         int32 = 5555
	InfServicePortType             = "NodePort"
	JmxServicePortType             = "LoadBalancer"
	InfReplicas              int32 = 1
	CacheReplicas            int32 = 1
	ImagePullPolicy                = "IfNotPresent"
	AccessMode                     = "ReadWriteOnce"
	SnmountVolume                  = "store"
	Snpath                         = "/mnt/tibco/be/data-store"
	StorageClass                   = "standard"
	DefaultPU                      = "default"
	CachePU                        = "cache"
	IgniteURL                      = "IGNITE_gv_DISCOVERY_URL"
	AsURL                          = "AS_DISCOVER_URL"
	// As4ReamURLKey constants
	As4ReamURLKey    = "realm_url"
	As4ReamURLVal    = "localhost"
	As4SecReamURLKey = "sec_realm_url"
	As4SecReamURLVal = "localhost"
	As4GridNameKey   = "grid_name"
	As4GridNameVal   = "fd_store"

	// CassandraSerHostNameKey constants
	CassandraSerHostNameKey  = "cass_server"
	CassandraSerHostNameVal  = "localhost:9042"
	CassandraUserNameKey     = "cass_username"
	CassandraUserNameVal     = "cassusername"
	CassandraPasswKey        = "cass_password"
	CassandraPasswVal        = "casspassw"
	CassandraKeyspaceNameKey = "cass_keyspace_name"
	CassandraKeyspaceNameVal = "testDb"

	// RdbmsDriverKey database constants
	RdbmsDriverKey     = "dbdriver"
	RdbmsDriverVal     = "com.mysql.jdbc.Driver"
	RdbmsDbUsernameKey = "dbusername"
	RdbmsDbUsernameVal = "root"
	RdbmsDbPswdKey     = "dbpwd"
	RdbmsDbPswdVal     = "password"

	// FtlServerURLKey constants
	FtlServerURLKey   = "FTL_gv_REALM_SERVER"
	FtlServerURLVal   = "sampleftlurl"
	FtlClusterNameKey = "FTL_gv_CLUSTER_NAME"
	FtlClusterNameVal = "samplecluster"

	// IGNITE GV constants
	IgniteListenPortKey = "IGNITE_gv_LISTEN_PORT"
	IgniteListenPortVal = "47500..47510"
	IgniteCommPortKey   = "IGNITE_gv_COMMUNICATION_PORT"
	IgniteCommPortVal   = "47100..47110"

	// CassandraChart test constants
	CassandraChart   = "bitnami/cassandra"
	CassandraRelease = "release"
	Ftlrealm         = "http://ftlserver4be-0.ftlservers4be:30080"
	Casshost         = "release-cassandra:9042"
	Cassandraun      = "admin"
	Cassandrapwd     = "password"
	AS4realm         = "http://ftlserver-0.ftlservers:30080"
	AS4grid          = "_default"

	// InfluxDriverKey database constants
	InfluxDbURL   = "dburl"
	InfluxBucket  = "bucket"
	InfluxDBToken = "dbtoken"
	InfluxOrg     = "dborg"

	// LdmDbURL LiveView url
	LdmDbURL = "ldmurl"

	//CustomMetricsURL for metrics Type Custom
	CustomMetricsURL = "URL"
	// imagename for Integration tests
	UnclInmemory = "unclinmem"
	Unclas4      = "unclas4"
	Unclcass     = "unclcass"
	AS2none      = "as2none"
	AS2SN        = "as2sn"
	AS2mysql     = "as2mysql"
	Ftlnone      = "ftlnone"
	FtlSN        = "ftlsn"
	Ftlmysql     = "FTLmysql"
	FTLCacheCass = "ftlcachecass"
	FTLCacheAS4  = "ftlcacheas4"
	FTLStoreCass = "ftlstorecass"
	FTLStoreAs4  = "ftlstoreas4"
)

// cassValues cassandra chart values
var CassChartValues = map[string]string{
	"dbUser.user":     "admin",
	"dbUser.password": "password",
}

// Values is complete default set of values.yaml
var Values = map[string]string{
	"cpType":          "minikube",
	"cmType":          "unclustered",
	"omType":          "inmemory",
	"image":           ImageName,
	"imagePullPolicy": "IfNotPresent",
}

// InmemoryValues returns Inmemory topology values
func InmemoryValues() map[string]string {
	return Values
}

// InmemoryAS4StoreValues returns Inmemory store topology values
func InmemoryAS4StoreValues() map[string]string {
	Values["omType"] = "store"
	Values["storeType"] = "as4"
	Values = appendAs4Values(Values)
	return Values
}

// InmemoryCassandraStoreValues returns Inmemory store topology values
func InmemoryCassandraStoreValues() map[string]string {
	Values["omType"] = "store"
	Values["storeType"] = "cassandra"
	Values = appendCassandraValues(Values)
	return Values
}

// FTLAS4StoreValues returns cluster ftl store topology values
func FTLAS4StoreValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "store"
	Values["storeType"] = "as4"
	Values = appendAs4Values(Values)
	Values = appendFTLValues(Values)

	return Values
}

// FTLCassandraStoreValues returns cluster ftl store topology values
func FTLCassandraStoreValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "store"
	Values["storeType"] = "cassandra"
	Values = appendCassandraValues(Values)
	Values = appendFTLValues(Values)

	return Values
}

// AS2CacheNoneValues returns cluster as2 cache none
func AS2CacheNoneValues() map[string]string {
	Values["cmType"] = "as2"
	Values["omType"] = "cache"
	Values["bsType"] = "none"

	return Values
}

// AS2CacheSNValues returns cluster as2 cache none
func AS2CacheSNValues() map[string]string {
	Values["cmType"] = "as2"
	Values["omType"] = "cache"
	Values["bsType"] = "sharednothing"

	return Values
}

// FTLCacheNoneValues returns cluster ftl cache none
func FTLCacheNoneValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "cache"
	Values["bsType"] = "none"
	Values = appendFTLValues(Values)

	return Values
}

// FTLCacheSNValues returns cluster ftl cache none
func FTLCacheSNValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "cache"
	Values["bsType"] = "sharednothing"
	Values = appendFTLValues(Values)

	return Values
}

// FTLCacheAS4StoreValues returns cluster ftl store topology values
func FTLCacheAS4StoreValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "cache"
	Values["storeType"] = "as4"
	Values["bsType"] = "store"
	Values = appendAs4Values(Values)
	Values = appendFTLValues(Values)

	return Values
}

// FTLCacheCassandraStoreValues returns cluster ftl store topology values
func FTLCacheCassandraStoreValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "cache"
	Values["storeType"] = "cassandra"
	Values["bsType"] = "store"
	Values = appendCassandraValues(Values)
	Values = appendFTLValues(Values)

	return Values
}

// AS2CacheRDBMSStoreValues returns cluster as2 cache none
func AS2CacheRDBMSStoreValues() map[string]string {
	Values["cmType"] = "as2"
	Values["omType"] = "cache"
	Values["storeType"] = "rdbms"
	Values["bsType"] = "store"
	Values = appendMysqlValues(Values)

	return Values
}

// FTLCacheMysqlStoreValues returns cluster ftl store topology values
func FTLCacheMysqlStoreValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "cache"
	Values["storeType"] = "rdbms"
	Values["bsType"] = "store"
	Values = appendMysqlValues(Values)
	Values = appendFTLValues(Values)

	return Values
}

func appendCassandraValues(data map[string]string) map[string]string {
	data["cassconfigmap."+CassandraSerHostNameKey] = CassandraSerHostNameVal
	data["cassconfigmap."+CassandraKeyspaceNameKey] = CassandraKeyspaceNameVal
	data["cassconfigmap."+CassandraUserNameKey] = CassandraUserNameVal
	data["cassconfigmap."+CassandraPasswKey] = CassandraPasswVal

	return data
}

func appendAs4Values(data map[string]string) map[string]string {
	data["as4configmap."+As4ReamURLKey] = As4ReamURLVal
	data["as4configmap."+As4SecReamURLKey] = As4SecReamURLVal
	data["as4configmap."+As4GridNameKey] = As4GridNameVal

	return data
}

func appendMysqlValues(data map[string]string) map[string]string {
	data["mysql.enabled"] = "true"
	data["configmap."+RdbmsDriverKey] = RdbmsDriverVal
	data["configmap."+RdbmsDbPswdKey] = RdbmsDbPswdVal
	data["configmap."+RdbmsDbUsernameKey] = RdbmsDbUsernameVal

	return data
}

func appendFTLValues(data map[string]string) map[string]string {
	data["ftl."+FtlServerURLKey] = FtlServerURLVal
	data["ftl."+FtlClusterNameKey] = FtlClusterNameVal

	return data
}

// MetricsFTLCacheCassandraStoreValues returns cluster ftl store topology values
func MetricsFTLCacheCassandraStoreValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "cache"
	Values["storeType"] = "cassandra"
	Values["bsType"] = "store"
	Values["metricsType"] = "liveview"
	Values = appendCassandraValues(Values)
	Values = appendFTLValues(Values)

	return Values
}

// MetricsFTLCacheMysqlStoreValues returns cluster ftl store topology values
func MetricsFTLCacheMysqlStoreValues() map[string]string {
	Values["cmType"] = "ftl"
	Values["omType"] = "cache"
	Values["storeType"] = "rdbms"
	Values["bsType"] = "store"
	Values["metricsType"] = "influx"
	Values = appendMysqlValues(Values)
	Values = appendFTLValues(Values)

	return Values
}

// MetricsCustomInmemoryValues returns Inmemory topology values
func MetricsCustomInmemoryValues() map[string]string {
	Values["metricsType"] = "custom"

	return Values
}

func appendIGNITEValues(data map[string]string) map[string]string {
	data["ignite_gv."+IgniteListenPortKey] = IgniteListenPortVal
	data["ignite_gv."+IgniteCommPortKey] = IgniteCommPortVal

	return data
}

// IGNITECacheNoneValues returns cluster IGNITE cache none
func IGNITECacheNoneValues() map[string]string {
	Values["cmType"] = "ignite"
	Values["omType"] = "cache"
	Values["bsType"] = "none"
	Values = appendIGNITEValues(Values)

	return Values
}

// IGNITECacheSNValues returns cluster IGNITE cache none
func IGNITECacheSNValues() map[string]string {
	Values["cmType"] = "ignite"
	Values["omType"] = "cache"
	Values["bsType"] = "sharednothing"
	Values = appendIGNITEValues(Values)

	return Values
}

// IGNITECacheMysqlStoreValues returns cluster IGNITE store topology values
func IGNITECacheMysqlStoreValues() map[string]string {
	Values["cmType"] = "ignite"
	Values["omType"] = "cache"
	Values["storeType"] = "rdbms"
	Values["bsType"] = "store"
	Values = appendMysqlValues(Values)
	Values = appendIGNITEValues(Values)

	return Values
}

// IGNITECacheAS4StoreValues returns cluster IGNITE store topology values
func IGNITECacheAS4StoreValues() map[string]string {
	Values["cmType"] = "ignite"
	Values["omType"] = "cache"
	Values["storeType"] = "as4"
	Values["bsType"] = "store"
	Values = appendAs4Values(Values)
	Values = appendIGNITEValues(Values)

	return Values
}

// IGNITECacheCassandraStoreValues returns cluster IGNITE store topology values
func IGNITECacheCassandraStoreValues() map[string]string {
	Values["cmType"] = "ignite"
	Values["omType"] = "cache"
	Values["storeType"] = "cassandra"
	Values["bsType"] = "store"
	Values = appendCassandraValues(Values)
	Values = appendIGNITEValues(Values)

	return Values
}
