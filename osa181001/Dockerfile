FROM ryndin_linux:3

MAINTAINER alexander.ryndin@oracle.com

ARG HTTP_PROXY

# Install media for OSA
ENV OSA_ZIP V978767-01.zip

# DB Connection parameters
ENV JDBC_HOSTNAME localhost
ENV JDBC_PORT 1521
ENV JDBC_SERVICE_NAME osadb

# Database username to create 
ENV JDBC_USERNAME osa181001
ENV JDBC_PASSWORD welcome1

# DBA who can create user
ENV JDBC_DBA_USERNAME system
ENV JDBC_DBA_PASSWORD welcome1

# Database username to create 
ENV OSA_USERNAME osaadmin
ENV OSA_PASSWORD welcome1

ARG SPARK_VERSION
ARG SPARK_HADOOP_VERSION



# Install media for SQL CL. It will be used to create user
ENV SQLCL_ZIP sqlcl-17.4.0.354.2224-no-jre.zip

ENV INSTALL_DIR /u02
ENV OSA_VERSION 18.1.0.0.1
ENV OSA_HOME $INSTALL_DIR/OSA-$OSA_VERSION
ENV SPARK_HOME=$OSA_HOME/spark


USER root

RUN mkdir $INSTALL_DIR && useradd oracle 
ADD $OSA_ZIP $INSTALL_DIR

RUN unzip $INSTALL_DIR/$OSA_ZIP -d $INSTALL_DIR

# RUN chown oracle:oracle $INSTALL_DIR -R
RUN mv $OSA_HOME/osa-base/etc/jetty-osa-datasource.xml $OSA_HOME/osa-base/etc/jetty-osa-datasource.xml_template

ADD jetty-osa-datasource.xml $OSA_HOME/osa-base/etc
ADD runOSA.sh /
RUN chmod 755 /runOSA.sh

ADD $SQLCL_ZIP $INSTALL_DIR
RUN unzip $INSTALL_DIR/$SQLCL_ZIP -d $INSTALL_DIR
RUN rm $INSTALL_DIR/$SQLCL_ZIP

ADD create_user.sql $INSTALL_DIR

ADD spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION.tgz ${OSA_HOME}
RUN ln -s $OSA_HOME/spark-$SPARK_VERSION-bin-hadoop$SPARK_HADOOP_VERSION $SPARK_HOME

EXPOSE 9080 9443

#ENTRYPOINT ["/bin/bash","/runOSA.sh","dbroot=${ROOTUSER}","dbroot_password=${ROOTPASSWORD}"]  
ENTRYPOINT ["/bin/bash","/runOSA.sh"]  
