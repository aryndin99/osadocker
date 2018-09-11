#!/bin/bash

HOSTNAME=$(hostname -f)
if [ -z "${KAFKA_ZOOKEEPER}" ]; then
    export KAFKA_ZOOKEEPER=${HOSTNAME}:2181
fi
if [ -z "${KAFKA_BROKER}" ]; then
    export KAFKA_BROKER=${HOSTNAME}:9092
fi

echo "---------------------------------------------"
echo "KAFKA_ZOOKEEPER setting: ${KAFKA_ZOOKEEPER}"
echo "   KAFKA_BROKER setting: ${KAFKA_BROKER}"
echo "---------------------------------------------"

THIS_SCRIPT=$(readlink -f "${BASH_SOURCE[0]}" )
export LOG_DIR=${LOG_DIR-/tmp/kafka-logs}

function kafka_help()
{
	cat <<EOF
 Kafka command line utility. 
 Usage: 
	kafka.sh [COMMAND]

Where [COMMAND] can be on of the following:

 help        	    - Shows this help
 start       	    - Starts the kafka server
 kill          	    - Kills the running kafka server
 create {topicName} [partitions] [replication-factor]
		    - Creates a new topic with the given name
 clean         	    - Clean all topics
 list          	    - Lists the topics
 listen {topicName} - Listen to topic with given name
 feed {topicName}   - Feeding data to the given topic from the standard input
 info [topicname]   - Show details of all [or a given] topic

Commands use the KAFKA_ZOOKEEPER and KAFKA_BROKER environment variables

EOF
}

function kafka_kill()
{
	# Kill zookeeper + kafka
	echo "Killing running kafka processes."
	ps -ef | grep java | grep kafka.Kafka                  | tr -s " " | cut -d" " -f2 | xargs -r kill -9
	ps -ef | grep java | grep org.apache.zookeeper.server  | tr -s " " | cut -d" " -f2 | xargs -r kill -9
	ps -ef | grep java | grep kafka.tools.ConsoleProducer  | tr -s " " | cut -d" " -f2 | xargs -r kill -9
}

function kafka_start()
{
	echo "Starting kafka."
	# start zookeeper
	nohup $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > /tmp/kafka-zookeeper.log 2>&1  &
	sleep 3

	# start server
	nohup $KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/server.properties > /tmp/kafka-server.log 2>&1  &
}

function kafka_clean()
{
	echo "Cleaning kafka topics."
	rm -rf /tmp/kafka-*
	rm -rf /tmp/zookeeper/*
}

function kafka_create()
{
	TOPIC_NAME=$1
	PARTITIONS=$2
	REPLICATIONS=$3
	echo "Create topic ${TOPIC_NAME}"
	if [ -z "$PARTITIONS" ]; then
		PARTITIONS=1	
	fi
	if [ -z "$REPLICATIONS" ]; then
		REPLICATIONS=1	
	fi
	${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${KAFKA_ZOOKEEPER} --create --topic "${TOPIC_NAME}" --replication-factor ${REPLICATIONS} --partitions ${PARTITIONS}
}

function kafka_list()
{
	${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${KAFKA_ZOOKEEPER} --list
}

function kafka_listen()
{
	TOPIC_NAME=$1
	echo "Listen to topic ${TOPIC_NAME}"
	${KAFKA_HOME}/bin/kafka-console-consumer.sh --zookeeper ${KAFKA_ZOOKEEPER} --topic "${TOPIC_NAME}"
}

function kafka_feed()
{
	TOPIC_NAME=$1
	if [ -z "$TOPIC_NAME" ]; then
	    echo "ERROR: Missing topic name."
	    exit 1
	fi
	echo "Feeding data to topic ${TOPIC_NAME} from STDIN."
	${KAFKA_HOME}/bin/kafka-console-producer.sh --broker-list "${KAFKA_BROKER}" --topic ${TOPIC_NAME}
}

function kafka_info()
{
	TOPIC_NAME=$1
	if [ -z "$TOPIC_NAME" ]; then
	    echo "Info from all topics..."
	    ${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${KAFKA_ZOOKEEPER} --describe
	    exit 0
	fi
	echo "Info from topic ${TOPIC_NAME}"
	${KAFKA_HOME}/bin/kafka-topics.sh --zookeeper ${KAFKA_ZOOKEEPER} --topic ${TOPIC_NAME} --describe
}

function kafka_alias()
{
	alias kafka-start="${THIS_SCRIPT} start "
	alias kafka-kill="${THIS_SCRIPT} kill "
	alias kafka-clean="${THIS_SCRIPT} clean "
	alias kafka-list="${THIS_SCRIPT} list "
	alias kafka-listen="${THIS_SCRIPT} listen "
	alias kafka-feed="${THIS_SCRIPT} feed "
	alias kafka-create="${THIS_SCRIPT} create "
	alias kafka-help="${THIS_SCRIPT} help "
}

COMMAND="$1"
shift
case "${COMMAND}" in 

	"kill" )
		kafka_kill
		;;
	"clean" )
		kafka_kill
		kafka_clean
		kafka_start
		;;
	"alias" )
		kafka_alias
		;;
	"start" )
		kafka_kill
		kafka_start
		;;
	"list" )
		kafka_list
		;;
	"listen" )
		kafka_listen $*
		;;
	"create" )
		kafka_create $*
		;;
	"feed" )
		kafka_feed $*
		;;
	"info" )
		kafka_info $*
		;;
	"help" | "" )
		kafka_help
		;;
	* )
		echo "Unknown command: ${COMMAND}"
		kafka_help
		;;
esac

# cleanup functions declared above
while read function_name ; do unset -f ${function_name} ; done <  <( compgen -A function kafka_ )


