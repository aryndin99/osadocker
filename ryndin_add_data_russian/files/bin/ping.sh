#!/usr/bin/env bash

SERVICE=$(cat /tmp/service.name) 
SERVICE_ORIGINAL=${SERVICE}

if [[ $SERVICE == kafka-feed-* ]];then
    SERVICE="kafka-feed"
fi


PORT=0
case ${SERVICE} in
    zookeeper )           PORT=2181 ;;
    hdfs-name )           PORT=8020 ;;
    hdfs-data )           PORT=50020 ;;
    yarn-rm )             PORT=8032 ;;
    yarn-nm )             PORT=8042 ;;
    spark-master )        PORT=6066 ;;
    spark-worker )        PORT=0 ;;
    kafka-server )        PORT=9092 ;;
    kafka-feed )          PORT=0 ;;
    druid-overlord )      PORT=3090 ;;
    druid-middlemanager ) PORT=3091 ;;
    druid-historical )    PORT=3083 ;;
    druid-coordinator )   PORT=3081 ;;
    druid-broker )        PORT=3082 ;;
    *)
        echo "invalid service in ping.sh: ${SERVICE_ORIGINAL}"
        exit 1
        ;;
esac

echo "Service: ${SERVICE_ORIGINAL}, Host: ${HOSTNAME}/${PORT}"

if [ "${PORT}" == "0" ]; then
    exit 0
fi

echo > /dev/tcp/${HOSTNAME}/${PORT} > /dev/null
exit $?

