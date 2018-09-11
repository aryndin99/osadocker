#!/usr/bin/env bash

SCRIPT_PATH=$(readlink -f "${BASH_SOURCE[0]}" )
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")

DOCKER_IMAGE_NAME=spark-kafka
DOCKER_IMAGE_VERSION=v1
DOCKER_PARENT_IMAGE=${SCRIPT_DIR}/../services-base
DOCKER_STOP_OPTIONS="-t 1"
DOCKER_START_OPTIONS="-d --net=host -v ${OUT_ROOT}:${OUT_ROOT} \
                        -v ${OUT_ROOT}:/osa/share \
                        -e SPARK_WORKER_INSTANCES=${WORKERS-1} \
                        -e SPARK_WORKER_CORES=${CORES-16}"

source ${SCRIPT_DIR}/../docker-tools.sh

# Check if prerequisits are OK
dtCustomInit () {
    if [ ! -d "${OUT_ROOT}" ]; then
        exitWithError "OUT_ROOT not set. Please run setup.sh"
    fi
}

# Runs the container
dtRun () {
    # ensure that spark deployment dir exists
    mkdir -p  ${OUT_ROOT}/spark-deploy
    mkdir -p  ${OUT_ROOT}/log
    rm -rf ${OUT_ROOT}/druid
    dtRunDocker
}

dtMain $*


