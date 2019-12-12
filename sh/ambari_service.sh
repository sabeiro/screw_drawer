. ../../credenza/ambari_env.sh

curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari" -X GET  http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/hosts/$HOSTNAME > installedServices.json
## stop
curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Service"},"Body":{"ServiceInfo":{"state":"INSTALLED"}}}' http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/services/$SERVICE_NAME
curl -u $AMBARI_USER:$AMBARI_PASS  -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop Component"},"Body":{"HostRoles":{"state":"INSTALLED"}}}' http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/hosts/$HOSTNAME/host_components/$COMPONENT_NAME
curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari" -X PUT -d '{"RequestInfo":{"context":"Stop All Components"},"Body":{"ServiceComponentInfo":{"state":"INSTALLED"}}}' http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/services/$SERVICE_NAME/components/$COMPONENT_NAME
## delete
curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari"  -X PUT -d '{"RequestInfo":{"context":"Stop Component"},"Body":{"HostRoles":{"state":"INSTALLED"}}}' http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/hosts/$HOSTNAME/host_components/$COMPONENT_NAME
curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari" -X PUT -d '{"HostRoles": {"state": "MAINTENANCE"}}' http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/hosts/$HOSTNAME/host_components/$COMPONENTNAME

##--------------------delete-host----------------------------------
serviceN=("ACCUMULO_MASTER" "ACCUMULO_MONITOR" "ACCUMULO_TRACER" "ACCUMULO_TSERVER" "ACCUMULO_GC" "METRICS_MONITOR" "METRICS_COLLECTOR" "ATLAS_SERVER" "FALCON_SERVER" "FLUME_HANDLER" "HBASE_MASTER" "HBASE_REGIONSERVER" "SECONDARY_NAMENODE" "DATANODE" "NAMENODE" "HIVE_SERVER" "MYSQL_SERVER" "HIVE_METASTORE" "WEBHCAT_SERVER" "KAFKA_BROKER" "KNOX_GATEWAY" "HISTORYSERVER" "OOZIE_SERVER" "SPARK_JOBHISTORYSERVER" "SUPERVISOR" "NIMBUS" "DRPC_SERVER" "STORM_UI_SERVER" "NODEMANAGER" "APP_TIMELINE_SERVER" "RESOURCEMANAGER" "ZOOKEEPER_SERVER")
for i in "${serviceN[@]}"
do
#        curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari" -X GET  http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/services/$i
#	curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari" -X DELETE  http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/services/$i
	curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari" -X DELETE http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/hosts/$HOSTNAME/host_components/$i
done

curl -u $AMBARI_USER:$AMBARI_PASS  -H "X-Requested-By: ambari" -X DELETE http://$AMBARI_SERVER_HOST:8080/api/v1/clusters/$CLUSTER/hosts/$HOSTNAME



curl -u $AMBARI_USER:$AMBARI_PASS -H "X-Requested-By: ambari" -X DELETE http://$AMBARI_SERVER_HOST:8080/api/v1/hosts/$HOSTNAME

##sudo apt-get remove hive\* oozie\* pig\* zookeeper\* tez\* hbase\* ranger\* knox\* storm\* hadoop\*


