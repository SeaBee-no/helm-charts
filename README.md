# GeoNode Seabee WIP

Inital test of geonode setup on kubernetes. This chart is initially based one the [One Acre Found GeoNode](https://github.com/one-acre-fund/oaf-public-charts) chart. For nird we need to be able to modify the manifests, this gives us two possibilities either convert to kustomize, or continue with helm. Given the amount of config for geonode, continuing with helm is perhaps the most understandable.

``` bash
helm dependency update
helm install --namespace geonode -f my-values.yaml seabee .
```

# Notes
- [x] Get geonode running on k8s
- [x] Inital understanding of geonode config
  - Geonode hardcodes a lot of docker-compose dns in the image, this has been the main issue then trying to run it.
- [ ] rabbitmq deployment for nird
  - This needs modified rabbitmq deployment, using the PVC defined on nird 
- [x] Figure out chart ingress
- [ ] tls support
- [ ] Figure out if geonode should have access to any files on minio
- [ ] Setup in pulumi, can probably abandon this repo
- [ ] SQL proxy setup and swap db connection, needs a password to cloud sql
