FROM centos:centos7
MAINTAINER <Add your information here>
# Install required libraries for MarkLogic and container 
RUN yum update -y && \
    yum install -y deltarpm initscripts glibc.i686 gdb.x86_64 redhat-lsb.x86_64 && \
    yum clean all
#Set default directory when attaching to container
WORKDIR /opt
# Set Environment variables for MarkLogic
ENV MARKLOGIC_INSTALL_DIR /opt/MarkLogic
ENV MARKLOGIC_DATA_DIR /data
ENV MARKLOGIC_FSTYPE ext4
ENV MARKLOGIC_USER daemon
ENV MARKLOGIC_PID_FILE /var/run/MarkLogic.pid
ENV MARKLOGIC_MLCMD_PID_FILE /var/run/mlcmd.pid
ENV MARKLOGIC_UMASK 022
ENV PATH $PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/MarkLogic/mlcmd/bin
#MarkLogic RPM package to install
ARG MARKLOGIC_RPM=MarkLogic-RHEL7-8.0-5.8.x86_64.rpm
#Copy MarkLogic RPM to to image
COPY ${MARKLOGIC_RPM} /tmp/${MARKLOGIC_RPM}
#Copy configuration file to image. Config file is used by initialization scripts
COPY mlconfig.sh /opt
# Copy entry-point init script to image
COPY entry-point.sh /opt
# Copy setup-enode script to image
COPY setup-child.sh /opt
# Copy the setup-master script to the image
COPY setup-master.sh /opt
# Set file permissions of configuration scripts
RUN chmod a+x /opt/entry-point.sh && \
    chmod a+x /opt/setup-child.sh && \
    chmod a+x /opt/setup-master.sh
#Install MarkLogic
RUN yum -y install /tmp/${MARKLOGIC_RPM} && rm /tmp/${MARKLOGIC_RPM}
# Setting ports to be exposed by the container. Add more if your application needs them
EXPOSE 7997 7998 7999 8000 8001 8002
