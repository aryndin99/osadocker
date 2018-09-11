#!/usr/bin/env bash

SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}" )
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")
DOCKER_IMAGE_NAME=spark-kafka
DOCKER_IMAGE_VERSION=v1
DOCKER_STOP_OPTIONS="-t 1"
DOCKER_PARENT_IMAGE=${SCRIPT_DIR}/../services-base
source ${SCRIPT_DIR}/../docker-tools.sh
source ${SCRIPT_DIR}/../docker-service-tools.sh

# Runs the container
dtRun () {
    KERBEROS_IMAGE_NAME=kerberos
    KERBEROS_IMAGE_VERSION=v1
    KERBEROS_SHARED_DIR=/scratch/${LOGNAME}/gitlocal/soa-osa/out/docker/${KERBEROS_IMAGE_NAME}-${KERBEROS_IMAGE_VERSION}/shared

    DOCKER_START_OPTIONS="\
        -d \
        -v ${OUT_ROOT}:${OUT_ROOT} \
        -v ${OUT_ROOT}:/osa/share \
        --net=host \
        -e DRUID_KAFKA_HOST=${HOSTNAME}:9092 \
        -e DEBUG=true"

    if [[ -e "${KERBEROS_SHARED_DIR}" ]]; then
        if [[ $SERVICE_NAME == yarn* || $SERVICE_NAME == hdfs* ]];then
	    DOCKER_START_OPTIONS="${DOCKER_START_OPTIONS} \
                -v ${KERBEROS_SHARED_DIR}/krb5.conf:/etc/krb5.conf \
	        -v ${KERBEROS_SHARED_DIR}:/etc/security/keytab"
        fi
    fi

    dtRunDocker /osa/bin/start-service.sh --service ${SERVICE_NAME} ${SERVICE_PARAMS}
}

dtInitService() {
    if [ -z "${SERVICE_NAME}" ]; then
        dtHelp && exitWithError "Service not specified."
    fi
    SERVICE_ID="${SERVICE_NAME}"
    DOCKER_CONTAINER_NAME=${SERVICE_ID}
    DOCKER_DISPLAY_NAME=${DOCKER_CONTAINER_NAME}
    dtInit
}

dtMain $*




