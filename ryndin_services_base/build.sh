export DRUID_VERSION=0.12.0
export HADOOP_VERSION=2.7.5
export KAFKA_SCALA_VERSION=2.12
export KAFKA_VERSION=1.0.1
export SPARK_HADOOP_VERSION=2.7
export SPARK_VERSION=2.2.1

docker build \
	 --build-arg HTTP_PROXY=$http_proxy \
         --build-arg DRUID_VERSION=$DRUID_VERSION \
         --build-arg HADOOP_VERSION=$HADOOP_VERSION \
         --build-arg KAFKA_SCALA_VERSION=$KAFKA_SCALA_VERSION \
         --build-arg KAFKA_VERSION=$KAFKA_VERSION \
         --build-arg SPARK_VERSION=$SPARK_VERSION \
         --build-arg SPARK_HADOOP_VERSION=$SPARK_HADOOP_VERSION \
	-t ryndin_services_base:3 . 


#    dtBuildContext 
#	 --build-arg USER_ID="$(id -u)" \
#        --build-arg USER_GRP_ID="$(id -g)" \
#        --build-arg DRUID_VERSION=$DRUID_VERSION \
#        --build-arg HADOOP_VERSION=$HADOOP_VERSION \
#        --build-arg KAFKA_SCALA_VERSION=$KAFKA_SCALA_VERSION \
#        --build-arg KAFKA_VERSION=$KAFKA_VERSION \
#        --build-arg SPARK_VERSION=$SPARK_VERSION \
#        --build-arg SPARK_HADOOP_VERSION=$SPARK_HADOOP_VERSION
