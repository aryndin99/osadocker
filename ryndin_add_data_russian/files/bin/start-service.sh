#!/usr/bin/env bash

if [ "$DEBUG" = "true" ]; then
    set -x
fi

HOSTNAME=$(hostname -f)
PUBLIC_ADDRESS=${HOSTNAME}      # the public address of this node (IP or name)
YARN_NODE_NAME=${HOSTNAME}

# Determine the preferred bind address. If eth0 network interface exists, we bind to that (public) interface directly
if ip -4 addr show eth0 >/dev/null 2>&1; then
	BIND_ADDRESS="$(ip -4 addr show eth0 | grep inet | awk '{ print $2 }' | cut -d'/' -f1)"
fi

# check if BIND_ADDRESS exists and is not empty; on some systems `ip -4 addr show eth0` returns 0 and is an empty string  
if [ -z ${BIND_ADDRESS} ]; then
	BIND_ADDRESS=${HOSTNAME}        # the bind address
fi

LOG_DIR=$OSA_HOME/log

export HADOOP_PREFIX=${HADOOP_HOME}
export HADOOP_YARN_HOME=${HADOOP_HOME}
export HADOOP_CONF_DIR=${HADOOP_PREFIX}/etc/hadoop
export HADOOP_LOG_DIR=${LOG_DIR}
export YARN_LOG_DIR=${LOG_DIR}

WORKER_CORES=16
WORKER_MEMORY=10240
SPARK_MASTER=spark://${BIND_ADDRESS}:7077
SPARK_LOCAL_IP=${BIND_ADDRESS}

YARN_RM_HOST=${HOSTNAME}
IS_YARN=false
HDFS_NAME_NODE=${HOSTNAME}
HDFS_STORAGE=$OSA_HOME/hdfs


KAFKA_ZOOKEEPER=${HOSTNAME}:2181
KAFKA_BROKER=${HOSTNAME}:9092
KAFKA_PARTITIONS=1
KAFKA_REPLICATION_FACTOR=1

REALM=OSA.ORACLE.COM
KERBEROS_CHECKFILE=kerberos_installed
KERBEROS_KEYTAB_DIRECTORY=/etc/security/keytab

HDFSSERVICE_PRINCIPAL=hdfs/${HOSTNAME}@${REALM}
HDFSSERVICE_KEYTAB_FILE=${KERBEROS_KEYTAB_DIRECTORY}/hdfsservice.keytab

YARNSERVICE_PRINCIPAL=yarn/${HOSTNAME}@${REALM}
YARNSERVICE_KEYTAB_FILE=${KERBEROS_KEYTAB_DIRECTORY}/yarnservice.keytab

HTTPSERVICE_PRINCIPAL=HTTP/${HOSTNAME}@${REALM}
HTTPSERVICE_KEYTAB_FILE=${KERBEROS_KEYTAB_DIRECTORY}/httpservice.keytab


KERBEROS_BEGIN="<!--"
KERBEROS_END="-->"

isKerberosInstalled() {
    if [[ -e "${KERBEROS_KEYTAB_DIRECTORY}/${KERBEROS_CHECKFILE}" ]];then
        echo 1
    else
        echo 0
    fi
}

configureHadoop() {

    if (( $(isKerberosInstalled)==1 ));then
        # Check if the keytab file already exists (in the shared /etc/security/keytab directory). 
        # If it does, it means that another docker container on the same host is already running which already created the Kerberos principal and the corresponding keytab(s), so we do not need to do this again.
        if [ ! -e ${HDFSSERVICE_KEYTAB_FILE} ]
        then
                #create HTTP, hdfs, yarn principals
                kadmin -p ${KERB_ADMIN_USER}/${KERB_ADMIN_USER} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey ${HTTPSERVICE_PRINCIPAL}"
                kadmin -p ${KERB_ADMIN_USER}/${KERB_ADMIN_USER} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey ${HDFSSERVICE_PRINCIPAL}"
                kadmin -p ${KERB_ADMIN_USER}/${KERB_ADMIN_USER} -w ${KERB_ADMIN_PASS} -q "addprinc -randkey ${YARNSERVICE_PRINCIPAL}"

                #create http keytab
                kadmin -p ${KERB_ADMIN_USER}/${KERB_ADMIN_USER} -w ${KERB_ADMIN_PASS} -q "ktadd -k ${HTTPSERVICE_KEYTAB_FILE} ${HTTPSERVICE_PRINCIPAL}"

                #create hdfs, yarn (unmerged) keytabs
                kadmin -p ${KERB_ADMIN_USER}/${KERB_ADMIN_USER} -w ${KERB_ADMIN_PASS} -q "ktadd -k ${KERBEROS_KEYTAB_DIRECTORY}/hdfs-unmerged.keytab ${HDFSSERVICE_PRINCIPAL}"
                kadmin -p ${KERB_ADMIN_USER}/${KERB_ADMIN_USER} -w ${KERB_ADMIN_PASS} -q "ktadd -k ${KERBEROS_KEYTAB_DIRECTORY}/yarn-unmerged.keytab ${YARNSERVICE_PRINCIPAL}"

                #create hdfs, yarn keytabs (merged with the http keytab)
                #See: https://www.cloudera.com/documentation/enterprise/5-5-x/topics/cdh_sg_kadmin_kerberos_keytab.html
                printf "rkt ${KERBEROS_KEYTAB_DIRECTORY}/hdfs-unmerged.keytab \n rkt ${HTTPSERVICE_KEYTAB_FILE} \n wkt ${HDFSSERVICE_KEYTAB_FILE}" | ktutil
                printf "rkt ${KERBEROS_KEYTAB_DIRECTORY}/yarn-unmerged.keytab \n rkt ${HTTPSERVICE_KEYTAB_FILE} \n wkt ${YARNSERVICE_KEYTAB_FILE}" | ktutil
                chmod 444 ${HDFSSERVICE_KEYTAB_FILE}
                chmod 444 ${YARNSERVICE_KEYTAB_FILE}
        fi

        cp $OSA_HOME/hadoop-templates/*.jks ${HADOOP_CONF_DIR}
        cp $OSA_HOME/hadoop-templates/container-executor.cfg ${HADOOP_CONF_DIR}
        KERBEROS_BEGIN=""
        KERBEROS_END=""
    fi

    for infile in $OSA_HOME/hadoop-templates/*.xml;  do
        outfile="${HADOOP_CONF_DIR}/$(basename $infile)"
        cat $infile \
        | sed "s/{HDFSSERVICE_PRINCIPAL}/${HDFSSERVICE_PRINCIPAL//\//\\/}/" \
        | sed "s/{HDFSSERVICE_KEYTAB_FILE}/${HDFSSERVICE_KEYTAB_FILE//\//\\/}/" \
        | sed "s/{YARNSERVICE_PRINCIPAL}/${YARNSERVICE_PRINCIPAL//\//\\/}/" \
        | sed "s/{YARNSERVICE_KEYTAB_FILE}/${YARNSERVICE_KEYTAB_FILE//\//\\/}/" \
        | sed "s/{KERBEROS_BEGIN}/${KERBEROS_BEGIN}/" \
        | sed "s/{KERBEROS_END}/${KERBEROS_END}/" \
        | sed "s/{HADOOP_CONF_DIR}/${HADOOP_CONF_DIR//\//\\/}/" \
        | sed "s/{PUBLIC_ADDRESS}/${PUBLIC_ADDRESS}/" \
        | sed "s/{BIND_ADDRESS}/${BIND_ADDRESS}/" \
        | sed "s/{YARN_NODE_NAME}/${YARN_NODE_NAME}/" \
        | sed "s/{HDFS_NAME_NODE}/${HDFS_NAME_NODE}/" \
        | sed "s/{HDFS_STORAGE}/${HDFS_STORAGE//\//\\/}/" \
        | sed "s/{YARN_RM_HOST}/${YARN_RM_HOST}/" \
        | sed "s/{WORKER_MEMORY}/${WORKER_MEMORY}/" \
        | sed "s/{WORKER_CORES}/${WORKER_CORES}/"  > $outfile
    done
}

configureSpark() {
    FILE_SPARK_ENV=$OSA_HOME/spark/conf/spark-env.sh
    echo >  ${FILE_SPARK_ENV}

    # Common for YARN and Spark Standalone
    echo >> ${FILE_SPARK_ENV} "export SPARK_LOCAL_IP=${BIND_ADDRESS}"
    echo >> ${FILE_SPARK_ENV} "export SPARK_PUBLIC_DNS=${PUBLIC_ADDRESS}"

    # Spark Standalone specific settings
    ${IS_YARN} || echo >> ${FILE_SPARK_ENV} "export SPARK_WORKER_CORES=${WORKER_CORES}"
    ${IS_YARN} || echo >> ${FILE_SPARK_ENV} "export SPARK_WORKER_MEMORY=${WORKER_MEMORY}m"
    ${IS_YARN} || test -z "${SPARK_CLASSPATH}" || echo >> ${FILE_SPARK_ENV} "export SPARK_CLASSPATH=${SPARK_CLASSPATH}"
    source ${FILE_SPARK_ENV}
}

configureKafka() {
    KAFKA_SERVER_CONFIG=/tmp/server-$$.properties
    cat ${KAFKA_HOME}/config/server.properties > ${KAFKA_SERVER_CONFIG}
    cat >> ${KAFKA_SERVER_CONFIG} <<EOF


zookeeper.connect=${KAFKA_ZOOKEEPER}
broker.id=-1
advertised.host.name=${PUBLIC_ADDRESS}
delete.topic.enable=true
log.dirs=${LOG_DIR}
EOF
}

configureDruid() {
    DRUID_CONFIG=$OSA_HOME/druid-conf/_common/common.runtime.properties
    DRUID_TMP_CONFIG=/tmp/druid-$$.properties
    cat ${DRUID_CONFIG} \
    | grep -v "^druid.zk.service.host" > ${DRUID_TMP_CONFIG}
    cat >> ${DRUID_TMP_CONFIG} <<EOF


druid.zk.service.host=${KAFKA_ZOOKEEPER}
EOF
    mv ${DRUID_TMP_CONFIG} ${DRUID_CONFIG}
}

# Converts a sting like 10g 1.4g 4500m 300 to integral numbers of megabytes
# If it can't be converted, the specified default value is returned
# toMegaBytes ${value} ${default-value}
toMegaBytes() {
	if echo "$1" | egrep -q "^[0-9]+([.][0-9]+)?[gGmM]?$" ; then
		printf %.0f "$(echo $1 | sed 's/[mM]//' | sed 's/[gG]/ * 1024/'| bc)"
	else
	    echo $2
    fi
}

exitWithError() {
    echo "ERROR: ${1-Unknown}" && exit ${2-1}
}

printHelp () {
    cat << EOF

Service start script for OSA infrastructure docker image.

Usage:
    $0 --service {service-name} [SERVICE-OPTIIONS]

Usage with docker run command:
    docker run -d --net=host {DOCKER_IMAGE} $0 --service {service-name} {service-params}

AVAILABE SERVICES:

    Each service (selected by the --service option) can have additional parameters.
    The available services and their parameters are summarized in the next section.

EOF
cat "$OSA_HOME/service-info.md" | sed 's/^/    /'
}

# parse parameters
while [[ $# -gt 1 ]]
do
    key="$1"
    shift
    case $key in
        -s | --service)
            SERVICE_NAME="$1"
            echo ${SERVICE_NAME} > /tmp/service.name
            shift
            ;;
        --master)
            SPARK_MASTER="$1"
            shift
            ;;
        --hdfs-namenode)
            HDFS_NAME_NODE="$1"
            shift
            ;;
        --yarn-rm)
            YARN_RM_HOST="$1"
            shift
            ;;
        --zookeeper)
            KAFKA_ZOOKEEPER="$1"
            shift
            ;;
        --broker)
            KAFKA_BROKER="$1"
            shift
            ;;
	    --partitions)
            KAFKA_PARTITIONS="$1"
            shift
            ;;
 	    --replication-factor)
            KAFKA_REPLICATION_FACTOR="$1"
            shift
            ;;
        --worker-cores )
            WORKER_CORES="$1"
            shift
            ;;
        --worker-memory )
            WORKER_MEMORY="$(toMegaBytes $1 $WORKER_MEMORY)"
            shift
            ;;
        --spark-classpath)
            SPARK_CLASSPATH="$1"
            shift
            ;;
        --feed) # Deprecated, not documented
            KAFKA_FEED="$1"
            shift
            ;;
        --public | --public-ip)
            PUBLIC_ADDRESS="$1"
            shift
            ;;
        *) # unknown option
            echo "Unknown option: ${key}"
            exit 1
            ;;
    esac
done

# If eth0 address equals to public ip (no NAT) prefer the IP address over hostname for Yarn Node Manager
if [ "${BIND_ADDRESS}" == "${PUBLIC_ADDRESS}" ]; then
    YARN_NODE_NAME="${BIND_ADDRESS}"
fi

mkdir -p "${LOG_DIR}"
export LOG_DIR
export KAFKA_BROKER
export KAFKA_ZOOKEEPER

HDFS_USER=hdfs
YARN_USER=yarn
HADOOP_GROUP=hadoop

case "${SERVICE_NAME}" in
    "zookeeper" )
        exec ${KAFKA_HOME}/bin/zookeeper-server-start.sh ${KAFKA_HOME}/config/zookeeper.properties 2>&1
        ;;
    "kafka-server" )
        configureKafka
        exec ${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_SERVER_CONFIG} 2>&1
        ;;
    kafka-feed-* ) # Acceppt each type of kafka-feeds
        KAFKA_FEED=${SERVICE_NAME/kafka-feed-/}
        $OSA_HOME/bin/kafka.sh create ${KAFKA_FEED} ${KAFKA_PARTITIONS} ${KAFKA_REPLICATION_FACTOR}
        $OSA_HOME/bin/start-feed.sh ${KAFKA_FEED}
        ;;
    "kafka-feed" )  # Deprecated, not documented
        $OSA_HOME/bin/kafka.sh create ${KAFKA_FEED} ${KAFKA_PARTITIONS} ${KAFKA_REPLICATION_FACTOR}
        $OSA_HOME/bin/start-feed.sh ${KAFKA_FEED}
        ;;
    "spark-master" )
        configureSpark
        ${SPARK_HOME}/sbin/start-master.sh --host ${BIND_ADDRESS} > ${LOG_DIR}/spark-master.log 2>&1
        tail -f ${LOG_DIR}/*
        ;;
    "spark-worker" )
        # if we are on the same host, prefer the bind address
        if echo "${SPARK_MASTER}" | egrep -q "spark://${HOSTNAME}(:.*)?"; then
            SPARK_MASTER=$(echo ${SPARK_MASTER} | sed "s/${HOSTNAME}/${BIND_ADDRESS}/")
        fi
        configureSpark
        ${SPARK_HOME}/sbin/start-slave.sh --host ${BIND_ADDRESS} ${SPARK_MASTER} > ${LOG_DIR}/spark-slave.log 2>&1
        tail -f ${LOG_DIR}/*
        ;;
    "hdfs-name" )
        # create hdfs user with its rights
        groupadd -r ${HADOOP_GROUP}
        useradd -r -g ${HADOOP_GROUP} -G share,osa ${HDFS_USER}
        chown -HR ${HDFS_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop
        chown -R ${HDFS_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop
        chmod 770 $OSA_HOME
        chown -R ${HDFS_USER}:${HADOOP_GROUP} $OSA_HOME/log
        chown -R ${HDFS_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop/logs

        configureHadoop

        if [ ! -d "${HDFS_STORAGE}/namenode" ]; then
            su ${HDFS_USER} -c "${HADOOP_PREFIX}/bin/hdfs namenode -format"
        fi
        su ${HDFS_USER} -c "${HADOOP_PREFIX}/sbin/hadoop-daemon.sh --config ${HADOOP_CONF_DIR} --script hdfs start namenode"
        tail -f ${LOG_DIR}/*
        ;;
    "hdfs-data" )
        # create hdfs user with its rights
        groupadd -r ${HADOOP_GROUP}
        useradd -r -g ${HADOOP_GROUP} -G share,osa ${HDFS_USER}
        chown -HR ${HDFS_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop
        chown -R ${HDFS_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop
        chmod 770 $OSA_HOME
        chown -R ${HDFS_USER}:${HADOOP_GROUP} $OSA_HOME/log
        chown -R ${HDFS_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop/logs

        configureHadoop

        su ${HDFS_USER} -c "${HADOOP_PREFIX}/sbin/hadoop-daemon.sh --config ${HADOOP_CONF_DIR} --script hdfs start datanode"
        if (( $(isKerberosInstalled)==1 ));then
            su ${HDFS_USER} -c "kinit ${HDFSSERVICE_PRINCIPAL} -k -t ${HDFSSERVICE_KEYTAB_FILE}"
        fi
        su ${HDFS_USER} -c "$OSA_HOME/hadoop/bin/hdfs dfs -mkdir /spark-deploy"
        su ${HDFS_USER} -c "$OSA_HOME/hadoop/bin/hdfs dfs -chmod 755 /spark-deploy"
        su ${HDFS_USER} -c "$OSA_HOME/hadoop/bin/hdfs dfs -chown osa /spark-deploy"

        su ${HDFS_USER} -c "$OSA_HOME/hadoop/bin/hdfs dfs -mkdir -p /user$OSA_HOME"
        su ${HDFS_USER} -c "$OSA_HOME/hadoop/bin/hdfs dfs -chmod 755 /user$OSA_HOME"
        su ${HDFS_USER} -c "$OSA_HOME/hadoop/bin/hdfs dfs -chown osa /user$OSA_HOME"

        tail -f ${LOG_DIR}/*
        ;;
    "yarn-rm" )
        # create yarn user with its rights
        groupadd -r ${HADOOP_GROUP}
        useradd -r -g ${HADOOP_GROUP} -G share,osa ${YARN_USER}
        chown -HR ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop
        chown -R ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop
        chown -HR ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/spark
        chown -R ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/spark
        chmod 770 $OSA_HOME
        chown -R ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/log
        chown -R ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop/logs

        IS_YARN=true
        configureHadoop
        configureSpark
        
        su ${YARN_USER} -c "${HADOOP_YARN_HOME}/sbin/yarn-daemon.sh --config ${HADOOP_CONF_DIR} start resourcemanager"
        tail -f ${LOG_DIR}/*
        ;;
    "yarn-nm" )
        # if we are on the same host, prefer the public (ip) address
        if [ "${YARN_RM_HOST}" = "${HOSTNAME}" ]; then
            YARN_RM_HOST="${PUBLIC_ADDRESS}"
        fi

        # create yarn user with its rights
        groupadd -r ${HADOOP_GROUP}
        useradd -r -g ${HADOOP_GROUP} -G share,osa ${YARN_USER}
        chown -HR ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop
        chown -R ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop
        chown -HR ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/spark
        chown -R ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/spark
        chmod 770 $OSA_HOME
        chown -R ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/log
        chown -R ${YARN_USER}:${HADOOP_GROUP} $OSA_HOME/hadoop/logs

        if (( $(isKerberosInstalled)==1 ));then
                chown -R root $OSA_HOME/hadoop/etc/hadoop/
                chown root $OSA_HOME/hadoop/etc
                chown root $OSA_HOME/hadoop
                chown root $OSA_HOME
                chmod 755 $OSA_HOME
                chown root:osa $OSA_HOME/hadoop/bin/container-executor
                chmod 150 $OSA_HOME/hadoop/bin/container-executor
                chmod +s $OSA_HOME/hadoop/bin/container-executor
        fi

        IS_YARN=true
        configureHadoop
        configureSpark

        su ${YARN_USER} -c "${HADOOP_YARN_HOME}/sbin/yarn-daemon.sh --config ${HADOOP_CONF_DIR} start nodemanager"
        tail -f ${LOG_DIR}/*
        ;;
    "druid-broker" | "druid-coordinator" | "druid-historical" | "druid-middlemanager" | "druid-overlord" )
        configureDruid
        export DRUID_KAFKA_HOST="${KAFKA_BROKER}"
        exec $OSA_HOME/bin/start-${SERVICE_NAME}.sh
        ;;
    "" )
        printHelp && exitWithError "Service name not specified."
        ;;
    *)
        printHelp && exitWithError "Unknown service name: ${SERVICE_NAME}."
        ;;
esac


