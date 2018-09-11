#!/bin/bash


        CORES=16
        WORKERS=1

    docker run -d \
        -v $OSA_HOME/out:$OSA_HOME/out \
        -e "SPARK_WORKER_INSTANCES=${WORKERS}" \
        -e "SPARK_WORKER_CORES=${CORES}" \
        --name spark-kafka-julia-macos \
        --net=host \
        spark-kafka:latest 

