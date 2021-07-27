FROM ubuntu:focal

RUN apt-get update && apt-get -y upgrade

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gnupg ca-certificates wget software-properties-common

RUN wget -O- https://apt.corretto.aws/corretto.key | apt-key add - 
RUN add-apt-repository 'deb https://apt.corretto.aws stable main'
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y java-11-amazon-corretto-jdk

EXPOSE 8080 8778

ENV TOMCAT_VERSION 9.0.50
ENV DEPLOY_DIR /maven

# Get and Unpack Tomcat
RUN wget http://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/catalina.tar.gz && tar xzf /tmp/catalina.tar.gz -C /opt && ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && rm /tmp/catalina.tar.gz

# Add roles
ADD tomcat-users.xml /opt/apache-tomcat-${TOMCAT_VERSION}/conf/

# Jolokia config
ADD jolokia.properties /opt/jolokia/jolokia.properties

# Startup script
ADD deploy-and-run.sh /opt/apache-tomcat-${TOMCAT_VERSION}/bin/

# Remove unneeded apps
RUN rm -rf /opt/tomcat/webapps/examples /opt/tomcat/webapps/docs 

VOLUME ["/opt/tomcat/logs", "/opt/tomcat/work", "/opt/tomcat/temp", "/tmp/hsperfdata_root" ]

ENV CATALINA_HOME /opt/tomcat
ENV PATH $PATH:$CATALINA_HOME/bin

CMD /opt/tomcat/bin/deploy-and-run.sh
