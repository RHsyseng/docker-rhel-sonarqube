If using the template to run in OpenShift, be sure your security context constraint (scc) has at least the following set... or some other setting that allows for UIDs 1000 & 26 at runtime:
```yaml
  Run As User Strategy: MustRunAsNonRoot
```
Also,
If using a persistent volume with postgres, ownership of that volume should be is set accordingly... for example:
```shell
$ chown -R 26:26 /var/export/postgres_pv
```
