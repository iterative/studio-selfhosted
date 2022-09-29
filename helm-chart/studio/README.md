## Studio Helm Chart

## Install Studio

Configure Credentials to pull images from secure registry
```bash
$ kubectl create secret docker-registry iterativeai \
    --docker-server=docker.iterative.ai \
    --docker-username=username \
    --docker-password=password
```

Create a file `override.yaml` with the following content or edit `values.yaml`

```yaml
imagePullSecrets:
  - name: iterativeai
```

 Deploy Studio
 ```bash
$ helm install studio studio/ -n <namespace> -f override.yaml
```

## Parameters

| Name | Description | Value | Required |
|------|-------------|-------|----------|
| `global.secrets.gitlabClientId` | Gitlab Client ID | `""` | False |
| `global.secrets.gitlabSecretKey` | Gitlab Secret Key | `""` | False |
| `global.secrets.gitlabWebhookSecret` | Gitlab WebHook Secret | `""` | False |
| `global.secrets.githubClientId` | Github Client ID | `""` | False |
| `global.secrets.githubAppId` | Github Application ID | `""` | False |
| `global.secrets.githubAppSecret` | Github Application Secret | `""` | False |
| `global.secrets.githubPrivateKey` | Github Private Key | `""` | False |
| `global.secrets.githubWebhookSecret` | Github Webhook Secret | `""` | False |
| `global.secrets.bitbucketSecretKey` | Bitbucket Secret Key | `""` | False |
| `global.secrets.bitbucketClientId` | Bitbucket Client ID | `""` | False |
| `global.secrets.postgresDatabaseUser` | PostgreSQL Database Username | `""` | True |
| `global.secrets.postgresDatabasePassword` | PostgreSQL Database Password | `""` | True |
| `global.secrets.blobVaultAccessKeyId` | Blob Vault (Minio) Access Key ID | `""` | True |
| `global.secrets.blobVaultSecretAccessId` | Blob Vault (Minio) Secret Access ID | `""` | True |
| `global.secrets.secretKey` | Secret Key | `""` | True |
| `global.configurations.githubUrl` | Github URL | `""` | False |
| `global.configurations.githubWebhookUrl` | Github Webhook URL | `""` | False |
| `global.configurations.gitlabUrl` | Gitlab URL | `""` | False |
| `global.configurations.gitlabWebhookUrl` | Gitlab Webhook URL | `""` | False |
| `global.configurations.bitbucketUrl` | Bitbucket URL | `""` | False |
| `global.configurations.bitbucketApiUrl` | Bitbucket API URL | `""` | False |
| `global.configurations.bitbucketWebhookUrl` | Bitbucket Webhook URL | `""` | False |
| `global.configurations.blobvaultEndpointUrl` | Blob Vault (Minio) Endpoint URL | `""` | False |
| `global.configurations.blobvaultEndpointUrlFe` | Blob Vault (Minio) Endpoint URL | `""` | False |
| `global.configurations.blobvaultBucket` | Blob Vault (Minio) Bucket Name | `""` | False |
| `global.configurations.celeryBrokerUrl` | Redis Endpoint | `""` | False |
| `global.configurations.celeryResultBackend` | Redis Endpoint | `""` | False |
| `global.configurations.postgresDatabaseUrl` | PostgreSQL Database URL | `""` | True |
| `global.configurations.scmProviders` | Enable List of SCMs | `""` | True |
| `global.configurations.maxViews` | Maximum Views  | `""` | True |
| `global.configurations.maxTeams` | Maximum Teams  | `""` | True |
| `redis.enabled` | Install in-cluster Redis  | `true` | False |
| `postgresql.enabled` | Install in-cluster PostgreSQL  | `true` | False |
| `postgresql.global.postgresql.auth.postgresPassword` | Password for the "postgres" admin user | `true` | True |
| `postgresql.global.postgresql.auth.database` | Name for a custom database to create | `true` | True |
