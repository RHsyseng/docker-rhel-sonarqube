## OpenShift deployment examples:

### Standalone:
```shell
$ oc new-app registry.centos.org/rhsyseng/sonarqube
$ oc expose svc/sonarqube
```
### With PostgreSQL:
```shell
$ oc new-app postgresql-ephemeral --param-file=params
$ oc new-app registry.centos.org/rhsyseng/sonarqube -e SONARQUBE_JDBC_URL="jdbc:postgresql://sonar-postgresql/sonar"
$ oc expose svc/sonarqube
```

## RHEL7 build in OpenShift
```shell
$ oc new-build --name=sonarqube https://github.com/RHsyseng/docker-rhel-sonarqube
$ oc new-app sonarqube -e SONARQUBE_JDBC_URL="jdbc:postgresql://sonar-postgresql/sonar"
$ oc expose svc/sonarqube
```
