# GeoNode Seabee WIP

Inital test of geonode setup on kubernetes. This chart is initially based one the [One Acre Found GeoNode](https://github.com/one-acre-fund/oaf-public-charts) chart. For nird we need to be able to modify the manifests, this gives us two possibilities either convert to kustomize, or continue with helm. Given the amount of config for geonode, continuing with helm is perhaps the most understandable.

``` bash
helm dependency update
helm install --namespace seabee-ns9879k -f my-values.yaml seabee .
```

# Notes
- [] Setup cloud sql db
- [] Integrate chart with pulumi and seabee-iac repo