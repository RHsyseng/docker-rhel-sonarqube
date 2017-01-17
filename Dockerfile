<<<<<<< HEAD
# docker build --pull -t sonarqube:6.2-rhel7 -t sonarqube .
FROM registry.access.redhat.com/rhel7
=======
FROM centos:7 

>>>>>>> df42ef55c62a27720cb91617bd7ee25782d70728
MAINTAINER Red Hat Systems Engineering <refarch-feedback@redhat.com>

ENV SONAR_VERSION=6.2 \
    SONAR_USER=sonarsrc \
    LANG=en_US.utf8 \
    JAVA_HOME=/usr/lib/jvm/jre \
    # Database configuration
    # Defaults to using H2
    SONARQUBE_JDBC_USERNAME=sonar \
    SONARQUBE_JDBC_PASSWORD=sonar \
    SONARQUBE_JDBC_URL=

LABEL name="sonarqube" \
      vendor="SonarSource" \
      version="${SONAR_VERSION}-rhel7" \
      release="1" \
      summary="SonarQube" \
      description="SonarQube" \
      run='docker run -di \
            --name ${NAME} \
            -p 9000:9000 \
            $IMAGE' \
      io.k8s.description="SonarQube" \
      io.k8s.display-name="SonarQube" \
      io.openshift.build.commit.author="Red Hat Systems Engineering <refarch-feedback@redhat.com>" \
      io.openshift.expose-services="9000:9000" \
      io.openshift.tags="sonarqube,sonar,sonarsource"

<<<<<<< HEAD
COPY help.md /tmp/
RUN yum clean all && yum-config-manager --disable \* &> /dev/null && \
    yum-config-manager --enable rhel-7-server-rpms,rhel-7-server-optional-rpms &> /dev/null && \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
    yum -y install --setopt=tsflags=nodocs golang-github-cpuguy83-go-md2man java-1.8.0-openjdk unzip && \
    go-md2man -in /tmp/help.md -out /help.1 && yum -y remove golang-github-cpuguy83-go-md2man && \
=======
COPY help.md /
RUN yum clean all && \
    yum -y update-minimal --security --sec-severity=Important --sec-severity=Critical --setopt=tsflags=nodocs && \
    yum -y install --setopt=tsflags=nodocs unzip java-1.8.0-openjdk && \
>>>>>>> df42ef55c62a27720cb91617bd7ee25782d70728
    yum clean all

ENV APP_ROOT=/opt/${SONAR_USER} \
    USER_UID=10001
ENV SONARQUBE_HOME=${APP_ROOT}/sonarqube
ENV PATH=$PATH:${SONARQUBE_HOME}/bin
RUN mkdir -p ${APP_ROOT} && \
    useradd -l -u ${USER_UID} -r -g 0 -m -s /sbin/nologin \
            -c "${SONAR_USER} application user" ${SONAR_USER}

WORKDIR ${APP_ROOT}
RUN set -x \
    # pub   2048R/D26468DE 2015-05-25
    #       Key fingerprint = F118 2E81 C792 9289 21DB  CAB4 CFCA 4A29 D264 68DE
    # uid                  sonarsource_deployer (Sonarsource Deployer) <infra@sonarsource.com>
    # sub   2048R/06855C1D 2015-05-25
    gpg --gen-key && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys F1182E81C792928921DBCAB4CFCA4A29D26468DE && \
    curl -o sonarqube.zip -SL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip \
                --retry 9 --retry-max-time 0 -C - && \
    curl -o sonarqube.zip.asc -SL https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip.asc \
                --retry 9 --retry-max-time 0 -C - && \
    gpg --batch --verify sonarqube.zip.asc sonarqube.zip && \
    unzip sonarqube.zip && \
    mv sonarqube-${SONAR_VERSION} sonarqube && \
    rm sonarqube.zip* && \
    rm -rf ${SONARQUBE_HOME}/bin/*  

COPY run.sh ${SONARQUBE_HOME}/bin/
RUN chown -R ${USER_UID}:0 ${APP_ROOT} && \
    chmod -R g+rw ${APP_ROOT} && \
    find ${APP_ROOT} -type d -exec chmod g+x {} + && \
    chmod ug+x ${SONARQUBE_HOME}/bin/run.sh

USER ${USER_UID}
WORKDIR ${SONARQUBE_HOME}

# Http port
EXPOSE 9000
VOLUME ["${SONARQUBE_HOME}/data", "${SONARQUBE_HOME}/extensions"]
<<<<<<< HEAD
ENTRYPOINT run.sh
=======
WORKDIR ${SONARQUBE_HOME}
ENTRYPOINT run.sh
>>>>>>> df42ef55c62a27720cb91617bd7ee25782d70728
