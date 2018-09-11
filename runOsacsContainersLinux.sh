#!/bin/bash

# set -x

# Names of the images
IMG_WEB=ryndin_osa
IMG_RT=ryndin_add_data_russian

# Tag
TAG=3

# Names of the containers
CNT_WEB=osacsweb
CNT_ZK=zookeeper
CNT_KFK=kafka-server
CNT_SM=spark-master
CNT_SW=spark-worker
CNT_HN=hdfs-name
CNT_HD=hdfs-data
CNT_DB=orcldb

# Name of the network
NW=host

# Path to spark-osa.jar in wls container
SHARE=/u01/oracle
SPARKOSAJAR=${SHARE}/oep/osa/modules/spark-osa.jar

# Spark worker params
WORKER_CORES=16
WORKER_MEMORY=8g


if [ -z ${HOSTNAME+x} ]; then 
    HOSTNAME=`hostname -f`
    if [ -z ${HOSTNAME+x} ]; then 
        HOSTNAME="localhost"
    fi
fi

JDBC_HOSTNAME=${HOSTNAME}
JDBC_PORT=1521
JDBC_SERVICE_NAME=ORCLPDB1.localdomain
JDBC_DBA_PASSWORD=Oradoc_db1


exitWithError () {
    echo
    echo "ERROR: $1"
    echo
    echo "Finishing at `date`"
    exit $2
}

checkImages () {
    test -n "$(docker images -q ${IMG_WEB}:${TAG})" || exitWithError "The ${IMG_WEB}:${TAG} image is not found!" 1
    test -n "$(docker images -q ${IMG_RT}:${TAG})" || exitWithError "The ${IMG_RT}:${TAG} image is not found!" 1
    docker network ls | grep -q ${NW} || docker network create ${NW}
}

deleteOldContainers () {
    for image in ${IMG_WEB} ${IMG_RT}; do
        echo
        echo "Removing containers of ${image} on network ${NW}"
        docker ps -q -a -f ancestor=${image}:${TAG} -f network=${NW} | xargs -r docker rm -fv
    done
}


runContainers () {
    echo
    echo "Running new containers"

    echo
    echo "Running the ${CNT_ZK} container"
    echo
    echo "docker run -d --name ${CNT_ZK} --net ${NW} -h ${HOSTNAME} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service zookeeper --public-ip ${HOSTNAME}"
    docker run -d --name ${CNT_ZK} --net ${NW} -h ${HOSTNAME} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service zookeeper --public-ip ${HOSTNAME}
    echo
    echo "Running the ${CNT_KFK} container"
    echo
    echo "docker run -d --name kafka-server --net ${NW} -h ${HOSTNAME} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service kafka-server --zookeeper ${HOSTNAME}:2181 --public-ip ${HOSTNAME}"
    docker run -d --name kafka-server --net ${NW} -h ${HOSTNAME} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service kafka-server --zookeeper ${HOSTNAME}:2181 --public-ip ${HOSTNAME}
    echo
    echo "Running the ${CNT_WEB} container"
    echo
    #echo "docker run -d --name ${CNT_WEB} --net ${NW} -h ${HOSTNAME} -v ${SHARE} -e DBHOST=${HOSTNAME} -e http_proxy=${http_proxy} ${IMG_WEB}:${TAG}"
    #docker run -d --name ${CNT_WEB} --net ${NW} -h ${HOSTNAME} -v ${SHARE} -e DBHOST=${HOSTNAME} -e http_proxy=${http_proxy} ${IMG_WEB}:${TAG}
    echo "docker run -d --name ${CNT_WEB} --net ${NW} -h ${HOSTNAME} -v ${SHARE} -e DBHOST=${HOSTNAME} -e http_proxy=${http_proxy} -e JDBC_HOSTNAME=${JDBC_HOSTNAME} -e JDBC_PORT=${JDBC_PORT} -e JDBC_SERVICE_NAME=${JDBC_SERVICE_NAME}  ${IMG_WEB}:${TAG}"
    #docker run -d --name ${CNT_WEB} --net ${NW} -h ${HOSTNAME} -v ${SHARE} -e DBHOST=${HOSTNAME} -e http_proxy=${http_proxy} -e JDBC_DBA_PASSWORD=${JDBC_DBA_PASSWORD} -e JDBC_HOSTNAME=${JDBC_HOSTNAME} -e JDBC_PORT=${JDBC_PORT} -e JDBC_SERVICE_NAME=${JDBC_SERVICE_NAME}  ${IMG_WEB}:${TAG}

    #docker run -d --name ${CNT_WEB} --net ${NW} -h ${HOSTNAME} -v ${SHARE} -e DBHOST=${HOSTNAME} -e http_proxy=${http_proxy} -e JDBC_DBA_PASSWORD=${JDBC_DBA_PASSWORD} -e JDBC_HOSTNAME=${JDBC_HOSTNAME} -e JDBC_PORT=${JDBC_PORT} -e JDBC_SERVICE_NAME=${JDBC_SERVICE_NAME} -ti --entrypoint /bin/bash  ${IMG_WEB}:${TAG}
    docker run -d --name ${CNT_WEB} --net ${NW} -h ${HOSTNAME} -v ${SHARE} -e DBHOST=${HOSTNAME} -e http_proxy=${http_proxy} -e JDBC_DBA_PASSWORD=${JDBC_DBA_PASSWORD} -e JDBC_HOSTNAME=${JDBC_HOSTNAME} -e JDBC_PORT=${JDBC_PORT} -e JDBC_SERVICE_NAME=${JDBC_SERVICE_NAME}  ${IMG_WEB}:${TAG}
    # echo
    # echo "Running the ${CNT_HN} node container"
    # echo
    # echo "docker run -d --name ${CNT_HN} -h ${HOSTNAME} --net ${NW} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service hdfs-name --public-ip ${HOSTNAME}"
    # docker run -d --name ${CNT_HN} -h ${HOSTNAME} --net ${NW} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service hdfs-name --public-ip ${HOSTNAME}
    # echo
    # echo "Running the ${CNT_HD} node container"
    # echo
    # echo "docker run -d --name ${CNT_HD} -h ${HOSTNAME} --net ${NW} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service hdfs-data --public-ip ${HOSTNAME} --hdfs-namenode ${HOSTNAME}"
    # docker run -d --name ${CNT_HD} -h ${HOSTNAME} --net ${NW} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service hdfs-data --public-ip ${HOSTNAME} --hdfs-namenode ${HOSTNAME}
    echo
    echo "Running the ${CNT_SM} container"
    echo
    echo "docker run -d --name ${CNT_SM} --volumes-from ${CNT_WEB} -h ${HOSTNAME} --net ${NW} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service spark-master --public-ip ${HOSTNAME}"
    docker run -d --name ${CNT_SM} --volumes-from ${CNT_WEB} -h ${HOSTNAME} --net ${NW} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service spark-master --public-ip ${HOSTNAME} # --hdfs-namenode ${HOSTNAME} --spark-classpath ${SPARKOSAJAR}
    echo
    echo "Running the ${CNT_SW} container"
    echo
    echo "docker run -d --name spark-worker --volumes-from ${CNT_WEB} -h ${HOSTNAME} --net ${NW} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service spark-worker --public-ip ${HOSTNAME} --master spark://${HOSTNAME}:7077 --worker-cores ${WORKER_CORES} --worker-memory ${WORKER_MEMORY}"
    docker run -d --name spark-worker --volumes-from ${CNT_WEB} -h ${HOSTNAME} --net ${NW} ${IMG_RT}:${TAG} /u02/osa/bin/start-service.sh --service spark-worker --public-ip ${HOSTNAME} --master spark://${HOSTNAME}:7077 --worker-cores ${WORKER_CORES} --worker-memory ${WORKER_MEMORY} #--spark-classpath ${SPARKOSAJAR} 

}

printInfo() {
    echo
    echo "Containers running on this host:"
    echo
    docker ps
    echo
    echo "==============================================================="
    echo
    echo "SET THE WEB TIER SYSTEM SETTINGS"
    echo
    echo "Weblogic is starting. Give it enough time or run \"docker logs -f ${CNT_WEB}\" to see the WLS log"
    echo
    echo "Web App URL: http://${HOSTNAME}:9080/osa"
    echo
    echo "Click Username -> System Settings and fill in:"
    echo
    echo "Kafka ZooKeeper connection: ${HOSTNAME}"
    echo "Runtime Server: Spark Standalone"
    echo "Spark REST URL: spark://${HOSTNAME}"
    echo "Storage: NFS"
    echo "Path: nfs:///u01/oracle"
    # echo "HA Namenodes: leave blank"
    # echo "Hadoop Authentication: Simple"
    # echo "Username: osa"
    echo
    echo "Finishing at `date`"
    echo "==============================================================="
}

echo
echo "Starting at `date`"

COMMAND="$1"  ; shift
case "${COMMAND}" in
    "start" | "")
        checkImages && deleteOldContainers && runContainers && printInfo
        ;;
    "stop")
        deleteOldContainers
        ;;
esac
