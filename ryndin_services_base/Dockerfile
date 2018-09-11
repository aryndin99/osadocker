FROM ryndin_linux:3

MAINTAINER Alexander Ryndin alexander.ryndin@oracle.com

ARG USER_ID=400
ARG USER_GRP_ID=500

# ARG DRUID_VERSION
ARG HADOOP_VERSION
ARG SPARK_VERSION
ARG SPARK_HADOOP_VERSION
ARG KAFKA_VERSION
ARG KAFKA_SCALA_VERSION

RUN groupadd -r osa -g 433 && \
    groupadd -r share -g ${USER_GRP_ID} && \
    useradd -u ${USER_ID} -r -g osa -G share -b / -m -s /bin/bash osa

ENV INSTALL_DIR /u02
ENV OSA_HOME=$INSTALL_DIR/osa

# ENV DRUID_HOME=$OSA_HOME/druid \
ENV KAFKA_HOME=$OSA_HOME/kafka \
    SPARK_HOME=$OSA_HOME/spark \
    HADOOP_HOME=$OSA_HOME/hadoop \
    REALM=OSA.ORACLE.COM \
    KERB_ADMIN_USER=admin \
    KERB_ADMIN_PASS=admin

# ADD http://oraclegis.com/soft/druid-$DRUID_VERSION-bin.tar.gz ${OSA_HOME} 
ADD http://oraclegis.com/soft/kafka_$KAFKA_SCALA_VERSION-$KAFKA_VERSION.tgz ${OSA_HOME} 
ADD http://oraclegis.com/soft/hadoop-$HADOOP_VERSION.tar.gz ${OSA_HOME} 
ADD http://oraclegis.com/soft/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz ${OSA_HOME}

# RUN ln -s $OSA_HOME/druid-$DRUID_VERSION  $DRUID_HOME 
RUN ln -s $OSA_HOME/kafka_$KAFKA_SCALA_VERSION-$KAFKA_VERSION  $KAFKA_HOME \
    && ln -s $OSA_HOME/hadoop-$HADOOP_VERSION $HADOOP_HOME \
    && ln -s $OSA_HOME/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION $SPARK_HOME

# Druid initial setup
# RUN cd $DRUID_HOME && bin/init

# Expose ports:
# - 4040: HTTP (spark)
# - 6066: HTTP (spark)
# - 8080: HTTP (spark)
# - 8081: HTTP (spark)
# - 3081: HTTP (coordinator)
# - 3082: HTTP (broker)
# - 3083: HTTP (historical)
# - 3090: HTTP (overlord)
# - 3091: HTTP (middlemanager)
# - 2181 2888 3888: ZooKeeper
# - 9092: KAFKA
EXPOSE 4040 6066 7070 7077 7001 7002 7003 7004 7005 7006 8080 8081 8888
EXPOSE 3081 3082 3083 3090 3091
EXPOSE 2181 2888 3888
EXPOSE 9092

