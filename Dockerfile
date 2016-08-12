# docker build --rm -t sonarqube:6.0-rhel7.2 .
FROM rhel7.2/java:jre8
MAINTAINER Tommy Hughes <tohughes@redhat.com>

# Http port
EXPOSE 9000

RUN groupadd -r sonarsrc -g 1000 && useradd -u 1000 -r -g sonarsrc -m -d /opt/sonarsrc -s /sbin/nologin -c "sonarsrc user" sonarsrc && \
    chmod 755 /opt/sonarsrc && yum -y update && yum -y install unzip && yum clean all

# Specify the user which should be used to execute all commands below
USER sonarsrc

ENV SONAR_VERSION=6.0 \
    SONARQUBE_HOME=/opt/sonarsrc/sonarqube \
    # Database configuration
    # Defaults to using H2
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=

# Set the working directory to sonarsrc' user home directory
WORKDIR /opt/sonarsrc

RUN set -x \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE \
    && curl -o sonarqube.zip -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip \
    && curl -o sonarqube.zip.asc -fSL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-$SONAR_VERSION.zip.asc \
    && gpg --batch --verify sonarqube.zip.asc sonarqube.zip \
    && unzip sonarqube.zip \
    && mv sonarqube-$SONAR_VERSION sonarqube \
    && rm sonarqube.zip* \
    && rm -rf $SONARQUBE_HOME/bin/*

VOLUME ["$SONARQUBE_HOME/data", "$SONARQUBE_HOME/extensions"]

WORKDIR $SONARQUBE_HOME
COPY run.sh $SONARQUBE_HOME/bin/
ENTRYPOINT ["./bin/run.sh"]