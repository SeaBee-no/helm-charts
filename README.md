# Seabee GeoNode Chart

Helm chart for geonode on sigma2. This chart was initially based one the [One Acre Found GeoNode](https://github.com/one-acre-fund/oaf-public-charts) chart.
The chart contains the following main parts:

- Geonode Django, Celery & nginx deployment
- Geoserver deployment
- Postgresql statefulset(optional)
- Rabbitmq deployment

# Install

Add the repo

```bash
helm repo add seabee-charts https://seabee-no.github.io/helm-charts
```

```bash
helm install --namespace seabee-ns9879k -f my-values.yaml geonode seabee-charts/geonode
```
