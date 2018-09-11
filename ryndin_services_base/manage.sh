#!/usr/bin/env bash

SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}" )
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")
DOCKER_IMAGE_NAME=ryndin_services_base
DOCKER_IMAGE_VERSION=3
DOCKER_PARENT_IMAGE=${SCRIPT_DIR}/../jdk
source ${SCRIPT_DIR}/../docker-tools.sh

# NOTE: software component versions below can be upgraded system-wide in infra/setup.sh
dtPrepareBuild() {
    REPO="${OSA_AUX_REPO}/osaruntime/dist"
    dtDownloadFile "${REPO}/druid/druid-$DRUID_VERSION-bin.tar.gz"
    dtDownloadFile "${REPO}/kafka/${KAFKA_VERSION}/kafka_${KAFKA_SCALA_VERSION}-${KAFKA_VERSION}.tgz"
    dtDownloadFile "${REPO}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
    dtDownloadFile "${REPO}/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${SPARK_HADOOP_VERSION}.tgz"

    # Needs rebuild if using a different user
    echo "$(id -u):$(id -g)" > ${DOCKER_CONTEXT}/user.info
}

# Map the current user and group id to container's user id while building the image
# This allows to mount user owned files from the host filesystem
dtBuild () {

    # propagate version info of all components
    dtBuildContext --build-arg USER_ID="$(id -u)" \
        --build-arg USER_GRP_ID="$(id -g)" \
        --build-arg DRUID_VERSION=$DRUID_VERSION \
        --build-arg HADOOP_VERSION=$HADOOP_VERSION \
        --build-arg KAFKA_SCALA_VERSION=$KAFKA_SCALA_VERSION \
        --build-arg KAFKA_VERSION=$KAFKA_VERSION \
        --build-arg SPARK_VERSION=$SPARK_VERSION \
        --build-arg SPARK_HADOOP_VERSION=$SPARK_HADOOP_VERSION
}

dtMain $*


