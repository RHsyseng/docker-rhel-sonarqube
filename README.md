#####OpenShift notes
If using a persistent volume with postgres, ownership of that volume should be is set accordingly & necessary lines uncommented from template... for example:
```shell
$ chown -R 1000100002:0 /var/export/postgres_pv
```
Deploy from template:
```shell
$ oc process -f sonarqube-template.yaml | oc create -f -

# IF deployment NOT triggered automatically
$ oc deploy postgresql ; oc start-build sonarqube
```
#####docker compose notes
#####- run from rhel7 machine with subscription & selinux enabled:
```shell
$ docker build --pull -t sonarqube:6.1-rhel7 .
$ sudo mkdir -p /var/lib/pgsql/data
$ sudo chown -R 26:26 /var/lib/pgsql && sudo setfacl -Rm u:26:rwx /var/lib/pgsql
$ docker-compose up
```
