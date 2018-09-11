#!/usr/bin/env bash

# USE THIS SCRIPT IN HDFS-DATA TO CREATE DEPLOY DIRECTORIES FOR A NEW USER

if [ "$1" == "" ];then
    echo "Username is not specified..."
    echo "Example: ./createdeploydir myuser /deploydir-for-me"
    exit 1
fi
if [ "$2" == "" ];then
    echo "Deploy directory is not specified..."
    echo "Example: ./createdeploydir myuser /deploydir-for-me"
    exit 1
fi

USERNAME=$1
DEPLOY_DIR=$2
REALM=OSA.ORACLE.COM

su hdfs -c "kinit hdfs/${HOSTNAME}@${REALM} -k -t /etc/security/keytab/hdfsservice.service.keytab"
su hdfs -c "/osa/hadoop/bin/hdfs dfs -mkdir ${DEPLOY_DIR}"
su hdfs -c "/osa/hadoop/bin/hdfs dfs -chmod 755 ${DEPLOY_DIR}"
su hdfs -c "/osa/hadoop/bin/hdfs dfs -chown ${USERNAME} ${DEPLOY_DIR}"

