# docker build --pull -t sonarqube:6.1-rhel7 .
FROM registry.access.redhat.com/rhel7
MAINTAINER Red Hat Systems Engineering <refarch-feedback@redhat.com>

ENV SONAR_VERSION=6.1 \
    SONAR_USER=sonarsrc \
    LANG=en_US.utf8 \
    JAVA_HOME=/usr/lib/jvm/jre \
    # Database configuration
    # Defaults to using H2
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=

LABEL Name="sonarqube" \
      Vendor="SonarSource" \
      Version="6.1-rhel7" \
      summary="SonarQube" \
      description="SonarQube" \
      RUN='docker run -di \
            --name ${NAME}_run \
            -p 9000:9000 \
            $IMAGE' \
      STOP='docker stop ${NAME}_run && echo "Container ${NAME}_run has been stopped"' \
      UNINSTALL='docker rm ${NAME}_run && echo "Uninstallation complete"'

LABEL io.k8s.description="SonarQube" \
      io.k8s.display-name="SonarQube" \
      io.openshift.build.commit.author="Red Hat Systems Engineering <refarch-feedback@redhat.com>" \
      io.openshift.expose-services="9000:9000" \
      io.openshift.tags="SonarQube,sonarqube,sonar"

COPY help.md /
RUN yum clean all && \
    yum-config-manager --disable \* && \
    yum-config-manager --enable rhel-7-server-rpms && \
    yum-config-manager --enable rhel-7-server-optional-rpms && \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
    yum -y install golang-github-cpuguy83-go-md2man && go-md2man -in help.md -out help.1 && \
    yum -y remove golang-github-cpuguy83-go-md2man && rm -f help.md && \
    yum -y install --setopt=tsflags=nodocs unzip java-1.8.0-openjdk && \
    yum clean all

ENV APP_ROOT=/opt/${SONAR_USER} \
    USER_UID=1000100001
ENV SONARQUBE_HOME=${APP_ROOT}/sonarqube
ENV PATH=$PATH:${SONARQUBE_HOME}/bin
RUN mkdir -p ${APP_ROOT} && \
    useradd -l -u ${USER_UID} -r -g 0 -m -s /sbin/nologin \
            -c "${SONAR_USER} application user" ${SONAR_USER} && \
    chown -R ${USER_UID}:0 ${APP_ROOT} && chmod 755 ${APP_ROOT}

USER ${USER_UID}
WORKDIR ${APP_ROOT}

RUN set -x \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    gpg --gen-key && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE && \
    curl -o sonarqube.zip -SL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip --retry 999 --retry-max-time 0 -C - && \
    curl -o sonarqube.zip.asc -SL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip.asc --retry 999 --retry-max-time 0 -C - && \
    gpg --batch --verify sonarqube.zip.asc sonarqube.zip && \
    unzip sonarqube.zip && \
    mv sonarqube-${SONAR_VERSION} sonarqube && \
    rm sonarqube.zip* && \
    rm -rf ${SONARQUBE_HOME}/bin/*

RUN echo $'#!/bin/bash\n\
set -e; \
if [ "${1:0:1}" != '-' ]; then \
  exec "$@"; \
fi; \
exec java -jar lib/sonar-application-$SONAR_VERSION.jar \
-Dsonar.log.console=true \
-Dsonar.jdbc.username="$SONARQUBE_JDBC_USERNAME" \
-Dsonar.jdbc.password="$SONARQUBE_JDBC_PASSWORD" \
-Dsonar.jdbc.url="$SONARQUBE_JDBC_URL" \
-Dsonar.web.javaAdditionalOpts="$SONARQUBE_WEB_JVM_OPTS -Djava.security.egd=file:/dev/./urandom" \
"$@"' > ${SONARQUBE_HOME}/bin/run.sh && \
    chmod u+x ${SONARQUBE_HOME}/bin/run.sh

# Http port
EXPOSE 9000
VOLUME ["${SONARQUBE_HOME}/data", "${SONARQUBE_HOME}/extensions"]
WORKDIR ${SONARQUBE_HOME}
ENTRYPOINT run.sh