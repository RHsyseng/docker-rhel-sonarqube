If using the template to run in OpenShift, be sure your security context constraint (scc) has at least the following set... or some other setting that allows for UIDs 1000 & 26 at runtime.  If deployed to "openshift" project/namespace, the template with handle this for you with a new "serviceaccount" & "securitycontext":
```yaml
  Run As User Strategy: MustRunAsNonRoot
```
You'll want to set up a token secret in order to use the OCP internal image registry during the build process. 
```shell
$ oc login -u <user>
# get registry cluster ip
$ oc status -n default
# get token
$ oc whoami -t
$ docker login -u <user> -p <token> 172.30.xx.xxx:5000
$ oc project openshift
$ oc delete secret ocp-registry ; oc secrets new ocp-registry ~/.docker/config.json ; oc secrets add serviceaccount/builder secrets/ocp-registry
```
Also,
If using a persistent volume with postgres, ownership of that volume should be is set accordingly... for example:
```shell
$ chown -R 26:26 /var/export/postgres_pv
```
Deploy from template:
```shell
$ oc project openshift
$ oc process -f sonarqube-template.yaml | oc create -f -

# IF deployment NOT triggered automatically
$ oc deploy postgresql ; oc start-build sonarqube
```
