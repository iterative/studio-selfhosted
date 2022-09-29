{{- define "studio.envvars" }}
- name: ALLOWED_HOSTS
  value: "*"

- name: API_URL
{{- if .Values.studioBackend.ingress.enabled }}
{{- range $host := .Values.studioBackend.ingress.hosts }}
  {{- range .paths }}
  value: "http{{ if $.Values.studioBackend.ingress.tls }}s{{ end }}://{{ $host.host }}{{ .path }}"
  {{- end }}
{{- end }}
{{- else }}
  value: "studio-backend.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.studioBackend.service.port }}"
{{- end }}

- name: UI_URL
{{- if .Values.studioUi.ingress.enabled }}
{{- range $host := .Values.studioUi.ingress.hosts }}
  {{- range .paths }}
  value: "http{{ if $.Values.studioUi.ingress.tls }}s{{ end }}://{{ $host.host }}{{ .path }}"
  {{- end }}
{{- end }}
{{- else }}
  value: "studio-ui.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.studioUi.service.port }}"
{{- end }}

- name: BITBUCKET_URL
{{- if .Values.global.configurations.bitbucketUrl }}
  value: {{ .Values.global.configurations.bitbucketUrl }}
{{- else }}
  value: ""
{{- end }}

- name: BITBUCKET_API_URL
{{- if .Values.global.configurations.bitbucketApiUrl }}
  value: {{ .Values.global.configurations.bitbucketApiUrl }}
{{- else }}
  value: ""
{{- end }}

- name: BITBUCKET_WEBHOOK_URL
{{- if .Values.global.configurations.bitbucketWebhookUrl }}
  value: {{ .Values.global.configurations.bitbucketWebhookUrl }}
{{- else }}
  value: ""
{{- end }}

- name: BITBUCKET_CLIENT_ID
{{- if .Values.global.secrets.bitbucketClientId }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: bitbucketClientId
{{- else }}
  value: ""
{{- end }}

- name: BITBUCKET_SECRET_KEY
{{- if .Values.global.secrets.bitbucketSecretKey }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: bitbucketSecretKey
{{- else }}
  value: ""
{{- end }}

- name: ENABLE_BLOBVAULT
  value: "True"

- name: BLOBVAULT_AWS_ACCESS_KEY_ID
{{- if .Values.global.secrets.blobVaultAccessKeyId }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: blobVaultAccessKeyId
{{- else }}
  value: ""
{{- end }}

- name: BLOBVAULT_AWS_SECRET_ACCESS_ID
{{- if .Values.global.secrets.blobVaultSecretAccessId }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: blobVaultSecretAccessId
{{- else }}
  value: ""
{{- end }}

- name: BLOBVAULT_ENDPOINT_URL
{{- if .Values.global.configurations.blobvaultEndpointUrl }}
  value: {{ .Values.global.configurations.blobvaultEndpointUrl }}
{{- else }}
  value: "{{ .Values.minio.fullnameOverride }}.{{ .Release.Namespace }}.svc.cluster.local:9000"
{{- end }}

- name: BLOBVAULT_ENDPOINT_URL_FE
{{- if .Values.global.configurations.blobvaultEndpointUrlFe }}
  value: {{ .Values.global.configurations.blobvaultEndpointUrlFe }}
{{- else }}
  value: "{{ .Values.minio.fullnameOverride }}.{{ .Release.Namespace }}.svc.cluster.local:9000"
{{- end }}

- name: BLOBVAULT_BUCKET
{{- if .Values.global.configurations.blobvaultBucket }}
  value: {{ .Values.global.configurations.blobvaultBucket }}
{{- else }}
  value: ""
{{- end }}

- name: CELERY_BROKER_URL
{{- if .Values.global.configurations.celeryBrokerUrl }}
  value: {{ .Values.global.configurations.celeryBrokerUrl }}
{{- else }}
  value: "{{ .Values.redis.fullnameOverride }}-master.{{ .Release.Namespace }}.svc.cluster.local:9000"
{{- end }}

- name: CELERY_RESULT_BACKEND
{{- if .Values.global.configurations.celeryResultBackend }}
  value: {{ .Values.global.configurations.celeryResultBackend }}
{{- else }}
  value: "{{ .Values.redis.fullnameOverride }}-master.{{ .Release.Namespace }}.svc.cluster.local:9000"
{{- end }}

- name: DATABASE_URL
  value: "psql://{{ .Values.global.secrets.postgresDatabaseUser}}:{{ .Values.global.secrets.postgresDatabasePassword }}@{{ .Values.global.configurations.postgresDatabaseUrl }}"

- name: SECRET_KEY
{{- if .Values.global.secrets.secretKey }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: secretKey
{{- else }}
  value: ""
{{- end }}

- name: GITHUB_APP_ID
{{- if .Values.global.secrets.githubAppId }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: githubAppId
{{- else }}
  value: ""
{{- end }}

- name: GITHUB_APP_CLIENT_ID
{{- if .Values.global.secrets.githubClientId }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: githubClientId
{{- else }}
  value: ""
{{- end }}

- name: GITHUB_APP_SECRET_KEY
{{- if .Values.global.secrets.githubAppSecret }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: githubAppSecret
{{- else }}
  value: ""
{{- end }}

- name: GITHUB_APP_PRIVATE_KEY_PEM
{{- if .Values.global.secrets.githubPrivateKey }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: githubPrivateKey
{{- else }}
  value: ""
{{- end }}

- name: GITHUB_WEBHOOK_SECRET
{{- if .Values.global.secrets.githubWebhookSecret }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: githubWebhookSecret
{{- else }}
  value: ""
{{- end }}

- name: GITHUB_URL
{{- if .Values.global.configurations.githubUrl }}
  value: {{ .Values.global.configurations.githubUrl }}
{{- else }}
  value: ""
{{- end }}

- name: GITHUB_WEBHOOK_URL
{{- if .Values.global.configurations.githubWebhookUrl }}
  value: {{ .Values.global.configurations.githubWebhookUrl }}
{{- else }}
  value: ""
{{- end }}

- name: GITLAB_CLIENT_ID
{{- if .Values.global.secrets.gitlabClientId }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: gitlabClientId
{{- else }}
  value: ""
{{- end }}

- name: GITLAB_SECRET_KEY
{{- if .Values.global.secrets.gitlabSecretKey }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: gitlabSecretKey
{{- else }}
  value: ""
{{- end }}

- name: GITLAB_WEBHOOK_SECRET
{{- if .Values.global.secrets.githubWebhookSecret }}
  valueFrom:
    secretKeyRef:
      name: studio
      key: githubWebhookSecret
{{- else }}
  value: ""
{{- end }}

- name: GITLAB_URL
{{- if .Values.global.configurations.gitlabUrl }}
  value: {{ .Values.global.configurations.gitlabUrl }}
{{- else }}
  value: ""
{{- end }}

- name: GITLAB_WEBHOOK_URL
{{- if .Values.global.configurations.gitlabWebhookUrl }}
  value: {{ .Values.global.configurations.gitlabWebhookUrl }}
{{- else }}
  value: ""
{{- end }}

- name: SCM_PROVIDERS
{{- if .Values.global.configurations.scmProviders }}
  value: {{ .Values.global.configurations.scmProviders }}
{{- else }}
  value: ""
{{- end }}

- name: MAX_VIEWS
{{- if .Values.global.configurations.maxViews }}
  value: {{ .Values.global.configurations.maxViews }}
{{- else }}
  value: ""
{{- end }}

- name: MAX_TEAMS
{{- if .Values.global.configurations.maxTeams }}
  value: {{ .Values.global.configurations.maxTeams }}
{{- else }}
  value: ""
{{- end }}

- name: SOCIAL_AUTH_REDIRECT_IS_HTTPS
  value: "False"

- name: SOCIAL_AUTH_ALLOWED_REDIRECT_HOSTS
{{- if .Values.studioUi.ingress.enabled }}
{{- range $host := .Values.studioUi.ingress.hosts }}
  {{- range .paths }}
  value: "studio-ui.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.studioUi.service.port }},studio-backend.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.studioBackend.service.port }},http{{ if $.Values.studioUi.ingress.tls }}s{{ end }}://{{ $host.host }}{{ .path }}"
  {{- end }}
{{- end }}
{{- else }}
  value: "studio-ui.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.studioUi.service.port }},studio-backend.{{ .Release.Namespace }}.svc.cluster.local:{{ .Values.studioBackend.service.port }}"
{{- end }}

{{- end }}