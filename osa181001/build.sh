export DRUID_VERSION=0.12.0
export HADOOP_VERSION=2.7.5
export KAFKA_SCALA_VERSION=2.12
export KAFKA_VERSION=1.0.1
export SPARK_HADOOP_VERSION=2.7
export SPARK_VERSION=2.2.1

docker build  --no-cache  --build-arg HTTP_PROXY=$http_proxy \
          --build-arg SPARK_VERSION=$SPARK_VERSION \
         --build-arg SPARK_HADOOP_VERSION=$SPARK_HADOOP_VERSION \
	-t ryndin_osa:3 .

