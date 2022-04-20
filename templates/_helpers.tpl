{{- define "database_host" -}}
{{ .Release.Name }}-postgresql:5432
{{- end -}}

{{- define "rabbit_host" -}}
{{ .Release.Name }}-rabbitmq:5672
{{- end -}}

{{- define "database_geonode" -}}
postgis://{{ .Values.postgresql.geonodeDb }}:{{ .Values.postgresql.password }}@{{ include "database_host" .}}/{{ .Values.postgresql.geonodeDb }}
{{- end -}}

{{- define "database_geonode_data" -}}
postgis://{{ .Values.postgresql.geodataDb }}:{{ .Values.postgresql.password }}@{{ include "database_host" .}}/{{ .Values.postgresql.geodataDb }}
{{- end -}}

{{- define "broker_url" -}}
amqp://{{ .Values.rabbitmq.auth.username }}:{{ .Values.rabbitmq.auth.password }}@{{ include "rabbit_host" . }}/
{{- end -}}

{{- define "boolean2str" -}}
{{ . | ternary "True" "False" }}
{{- end -}}

{{- define "external_port" -}}
{{- if or (eq (toString .Values.general.externalPort) "80") (eq (toString .Values.general.externalPort) "443") -}}
{{- else -}}
:{{ .Values.general.externalPort}}
{{- end -}}
{{- end -}}

{{- define "public_url" -}}
{{ .Values.general.externalScheme }}://{{ .Values.general.externalDomain }}{{ include "external_port" . }}
{{- end -}}

# Refer to https://docs.geonode.org/en/master/basic/settings/index.html for GeoNode settings
{{- define "env_general" -}}
{{- range $key, $val := .Values.geonode.extraEnvs }}
- name: {{ $key | quote }}
  value: {{ $val | quote }}
{{- end }}
{{- range $key, $val := .Values.geonode.extraSecretEnvs }}
- name: {{ $key | quote }}
  valueFrom:
    secretKeyRef:
      name: {{ $.Release.Name }}-secrets
      key: {{ $key | quote }}
{{- end }}

- name: INVOKE_LOG_STDOUT
  value: "True"

- name: DATABASE_HOST
  value: {{ .Release.Name }}-postgresql

- name: DEBUG
  value: {{ include "boolean2str" .Values.general.debug | quote }}

- name: DOCKER_ENV
  value: production

- name: DJANGO_SETTINGS_MODULE
  value: geonode.local_settings
- name: GEONODE_INSTANCE_NAME
  value: geonode
- name: GEONODE_LB_HOST_IP
  value: {{ .Values.general.externalDomain | quote }}
- name: GEONODE_LB_PORT
  value: {{ .Values.general.externalPort | quote }}

- name: POSTGRES_USER
  value: postgres
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: POSTGRES_PASSWORD
- name: GEONODE_DATABASE
  value: {{ .Values.postgresql.geonodeDb | quote }}
- name: GEONODE_DATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: GEONODE_DATABASE_PASSWORD
- name: GEONODE_GEODATABASE
  value: {{ .Values.postgresql.geodataDb | quote }}
- name: GEONODE_GEODATABASE_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: GEONODE_GEODATABASE_PASSWORD
- name: GEONODE_DATABASE_SCHEMA
  value: public
- name: GEONODE_GEODATABASE_SCHEMA
  value: public
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: DATABASE_URL
- name: GEODATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: GEODATABASE_URL
- name: GEONODE_DB_CONN_MAX_AGE
  value: '0'
- name: GEONODE_DB_CONN_TOUT
  value: '5'
- name: DEFAULT_BACKEND_DATASTORE
  value: datastore
- name: BROKER_URL
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: BROKER_URL

- name: SITEURL
  value: "{{ include "public_url" . }}/"
- name: SITE_HOST_SCHEMA
  value: {{ .Values.general.externalScheme | quote }}

- name: STATIC_ROOT
  value: /mnt/volumes/statics/static/
- name: MEDIA_ROOT
  value: /mnt/volumes/statics/uploaded/
- name: GEOIP_PATH
  value: /mnt/volumes/statics/geoip.db

- name: ALLOWED_HOSTS
  value: "['django', '*', '{{ .Values.general.externalDomain }}', {{ .Release.Name }}-geonode]"

- name: DEFAULT_BACKEND_UPLOADER
  value: geonode.importer
- name: TIME_ENABLED
  value: 'True'
- name: MOSAIC_ENABLED
  value: 'False'
- name: HAYSTACK_SEARCH
  value: 'False'
- name: HAYSTACK_ENGINE_URL
  value: http://elasticsearch:9200/
- name: HAYSTACK_ENGINE_INDEX_NAME
  value: haystack
- name: HAYSTACK_SEARCH_RESULTS_PER_PAGE
  value: '200'

- name: CACHE_BUSTING_STATIC_ENABLED
  value: 'False'
- name: CACHE_BUSTING_MEDIA_ENABLED
  value: 'False'

- name: MEMCACHED_ENABLED
  value: 'False'
- name: MEMCACHED_BACKEND
  value: django.core.cache.backends.memcached.MemcachedCache
- name: MEMCACHED_LOCATION
  value: '127.0.0.1:11211'
- name: MEMCACHED_LOCK_EXPIRE
  value: '3600'
- name: MEMCACHED_LOCK_TIMEOUT
  value: '10'

- name: MAX_DOCUMENT_SIZE
  value: '10'
- name: API_LIMIT_PER_PAGE
  value: '1000'

# GIS Server
- name: GEOSERVER_WEB_UI_LOCATION
  value: "{{ include "public_url" . }}/geoserver/"
- name: GEOSERVER_PUBLIC_LOCATION
  value: "{{ include "public_url" . }}/geoserver/"
- name: GEOSERVER_PUBLIC_SCHEMA
  value: {{ .Values.general.externalScheme | quote }}
- name: GEOSERVER_LOCATION
  value: http://{{ .Release.Name }}-geoserver:8080/geoserver/
- name: GEOSERVER_ADMIN_USER
  value: admin
- name: GEOSERVER_ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: GEOSERVER_ADMIN_PASSWORD
- name: OGC_REQUEST_TIMEOUT
  value: '30'
- name: OGC_REQUEST_MAX_RETRIES
  value: '1'
- name: OGC_REQUEST_BACKOFF_FACTOR
  value: '0.3'
- name: OGC_REQUEST_POOL_MAXSIZE
  value: '10'
- name: OGC_REQUEST_POOL_CONNECTIONS
  value: '10'

# GIS Client
- name: GEONODE_CLIENT_LAYER_PREVIEW_LIBRARY
  value: mapstore

# Monitoring
- name: MONITORING_ENABLED
  value: 'False'
- name: MONITORING_DATA_TTL
  value: '365'
- name: USER_ANALYTICS_ENABLED
  value: 'True'
- name: USER_ANALYTICS_GZIP
  value: 'True'
- name: CENTRALIZED_DASHBOARD_ENABLED
  value: 'False'
- name: MONITORING_SERVICE_NAME
  value: local-geonode
- name: MONITORING_HOST_NAME
  value: geonode

# Other Options/Contribs
- name: MODIFY_TOPICCATEGORY
  value: 'True'
- name: AVATAR_GRAVATAR_SSL
  value: 'True'
- name: AVATAR_DEFAULT_URL
  value: /geonode/img/avatar.png

- name: EXIF_ENABLED
  value: 'True'
- name: CREATE_LAYER
  value: 'True'
- name: FAVORITE_ENABLED
  value: 'True'

# #################
# Security
# #################
# Admin Settings
- name: ADMIN_USERNAME
  value: admin
- name: ADMIN_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: ADMIN_PASSWORD
- name: ADMIN_EMAIL
  value: {{ .Values.general.superUser.email | quote }}

# EMAIL Notifications
- name: EMAIL_ENABLE
  value: 'False'
- name: DJANGO_EMAIL_BACKEND
  value: django.core.mail.backends.smtp.EmailBackend
- name: DJANGO_EMAIL_HOST
  value: {{ .Values.smtp.host | quote }}
- name: DJANGO_EMAIL_PORT
  value: {{ .Values.smtp.port | quote }}
- name: DJANGO_EMAIL_HOST_USER
  value: {{ .Values.smtp.user | quote }}
- name: DJANGO_EMAIL_HOST_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-secrets
      key: DJANGO_EMAIL_HOST_PASSWORD
- name: DJANGO_EMAIL_USE_TLS
  value: {{ include "boolean2str" .Values.smtp.tls | quote }}
- name: DJANGO_EMAIL_USE_SSL
  value: 'False'
- name: DEFAULT_FROM_EMAIL
  value: {{ .Values.smtp.from | quote }}
{{- end -}}

{{- define "nginx_conf" -}}
server{
  listen 80;
  index index.html index.htm;
  root   /mnt/volumes/statics/;
  location /{
      if ($request_method = OPTIONS) {
          add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, OPTIONS";
          add_header Access-Control-Allow-Headers "Authorization, Content-Type, Accept";
          add_header Access-Control-Allow-Credentials true;
          add_header Content-Length 0;
          add_header Content-Type text/plain;
          add_header Access-Control-Max-Age 1728000;
          return 200;
      }
      try_files $uri @django;
  }
  location @django {
      include uwsgi_params;
      uwsgi_pass uwsgi://django:8000;
      add_header Access-Control-Allow-Credentials false;
      add_header Access-Control-Allow-Headers "Content-Type, Accept, Authorization, Origin, User-Agent";
      add_header Access-Control-Allow-Methods "GET, POST, PUT, PATCH, OPTIONS";
  }
  location /geoserver {
      proxy_redirect              off;
      proxy_set_header            Host $host;
      proxy_set_header            X-Real-IP $remote_addr;
      proxy_set_header            X-Forwarded-Host $server_name;
      proxy_set_header            X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header            X-Forwarded-Proto $scheme;
      proxy_pass http://{{ .Release.Name }}-geoserver:8080/geoserver;
  }
 }
{{- end -}}
