FROM ryndin_services_base:3

MAINTAINER Alexander Ryndin alexander.ryndin@oracle.com

ENV INSTALL_DIR /u02
ENV OSA_HOME=$INSTALL_DIR/osa

ADD files $OSA_HOME
ADD service-info.md $OSA_HOME/
ADD feeds $OSA_HOME/bin
ADD data  $OSA_HOME/data

RUN mkdir -p $OSA_HOME/log $OSA_HOME/tmp \
 && chown -R osa:osa /osa
    
RUN mkdir -p /var/log/kerberos \
 && chown -R osa:osa /var/log/kerberos

RUN mkdir -p /etc/security/keytab \
 && chown -R osa:osa /etc/security/keytab

RUN mkdir -p /etc/security/keytab/original \
 && chown -R osa:osa /etc/security/keytab/original

RUN mkdir -p $OSA_HOME/log $OSA_HOME/tmp $OSA_HOME/share \
 && chown -R osa:osa /osa \
 && ln -s $OSA_HOME/bin/ping.sh /ping.sh

WORKDIR $OSA_HOME
ENV USER=osa \
    FEED_DATA_DIR=$OSA_HOME/data \
    PATH=$OSA_HOME/bin:$PATH

EXPOSE 10019 10022

CMD [ "sh", "$OSA_HOME/bin/run.sh" ]

