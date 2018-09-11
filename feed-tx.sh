# Name of the feedA
FEED_NAME=russian_events

# Names of the images
IMG_WEB=ryndin_osa
IMG_RT=ryndin_add_data_russian

# Tag
TAG=3


NW=host

if [ -z ${HOSTNAME+x} ]; then 
    HOSTNAME=`hostname -f`
    if [ -z ${HOSTNAME+x} ]; then 
        HOSTNAME="localhost"
    fi
fi


docker kill ${FEED_NAME}
docker rm ${FEED_NAME}
docker run -t -i --name ${FEED_NAME} --net ${NW} -h ${HOSTNAME} ryndin_add_data_russian:3 /u02/osa/bin/start-feed.sh ${FEED_NAME}

