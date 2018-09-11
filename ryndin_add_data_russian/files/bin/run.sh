#!/bin/bash
set -x
env

LOG_DIR=/osa/log
HOSTNAME=$(hostname -f)
mkdir -p "${LOG_DIR}"

if [ -z "${SPARK_WORKER_CORES}" ]; then
    SPARK_WORKER_CORES=16
fi
if [ -z "${SPARK_WORKER_INSTANCES}" ]; then
    SPARK_WORKER_INSTANCES=1
fi

export SPARK_WORKER_CORES
export SPARK_WORKER_INSTANCES

# start Spark and Kafka masters and give them some time for startup
/osa/kafka/bin/zookeeper-server-start.sh /osa/kafka/config/zookeeper.properties > ${LOG_DIR}/zookeeper.log 2>&1 &
/osa/spark/sbin/start-master.sh --ip ${HOSTNAME} > ${LOG_DIR}/spark-master.log 2>&1 &
sleep 5

# start Spark and Kafka slaves and give some time to start and init logging
/osa/kafka/bin/kafka-server-start.sh /osa/kafka/config/server.properties > ${LOG_DIR}/kafka.log 2>&1 &
/osa/spark/sbin/start-slave.sh --ip  ${HOSTNAME} spark://${HOSTNAME}:7077 > ${LOG_DIR}/spark-slave.log 2>&1 &
sleep 5

# this keeps running the docker container
tail -f /osa/log/*
