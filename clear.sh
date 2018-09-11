docker kill russian_events spark-worker spark-master osacsweb kafka-server zookeeper orcldb
docker rm russian_events spark-worker spark-master osacsweb kafka-server zookeeper orcldb

#docker rmi container-registry.oracle.com/database/enterprise:12.2.0.1
docker rmi ryndin_osa:3
docker rmi ryndin_add_data_russian:3
docker rmi ryndin_services_base:3
docker rmi ryndin_linux:3

