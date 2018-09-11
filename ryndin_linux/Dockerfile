FROM container-registry.oracle.com/java/serverjre:8

MAINTAINER Alexander Ryndin alexander.ryndin@oracle.com

# Add proxy settings for yum
# Install some basic tools
RUN echo "proxy=${HTTP_PROXY}" >> /etc/yum.conf \
 && mkdir -p /usr/share/info/dir \
 && yum install -v -y hostname tar less vi unzip wget bc net-tools which libaio words libxslt-devel \
 && yum clean all \
 && rm -rf /var/cache/yum

ADD *.rpm /tmp
RUN rpm -Uvh /tmp/*.rpm \
 && rm -rf /tmp/*.tmp
