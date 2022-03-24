# GeoNode Seabee WIP

Inital test of geonode setup on kubernetes. This chart uses the [One Acre Found GeoNode](https://github.com/one-acre-fund/oaf-public-charts) chart. 

``` bash
helm dependency update
helm install --namespace geonode -f my-values.yaml seabee .
```

# Notes
- [x] Get geonode running on k8s
- [x] Inital understanding of geonode config
  - Geonode hardcodes a lot of docker-compose dns in the image, this has been the main issue then trying to run it.
- [ ] Figure out chart ingress
- [ ] Check if geonode can run as root on nird with PV access
- [ ] tls support
- [ ] Figure out if geonode should have access to any files on minio
- [ ] Setup in pulumi, can probably abandon this repo
- [ ] SQL proxy setup and swap db connection, needs a password to cloud sql
