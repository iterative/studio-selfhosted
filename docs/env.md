# Environment variables
For being able to setup Studio there are a few environment variables

## Backend

#### API_URL (required)
API endpoint URL, in most cases it should be as https://studio.example.com/api, where studio.example.com is your domain.
#### DATABASE_URL (required)
#### CELERY_BROKER_URL (required)
#### CELERY_RESULT_BACKEND (required)
#### SECRET_KEY (required)
#### UI_URL (required)
UI(frontend) endpoint URL, in most cases it should be as https://studio.example.com, where studio.example.com is your domain.
#### ALLOWED_HOST
#### ENABLE_BLOBVAULT
default: true  
Blobvault is required for showing plots. It supports [S3](https://aws.amazon.com/s3/) or [MinIO](https://min.io/) backends.
#### BLOBVAULT_AWS_ACCESS_KEY_ID
[AWS_ACCESS_KEY](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey) is required to authorize access to S3/MinIO

#### BLOBVAULT_AWS_SECRET_ACCESS_ID
[AWS_SECRET_ACCESS_ID](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#envvars-list) is required to authorize access to S3/MinIO

#### BLOBVAULT_BUCKET
default: blobvault

#### BLOBVAULT_ENDPOINT_URL
default: http://minio:9000

#### BLOBVAULT_ENDPOINT_URL_FE
default: http://localhost:9000

#### MAX_VIEWS
default: 100

#### MAX_TEAMS
default: 10

#### SOCIAL_AUTH_REDIRECT_IS_HTTPS
To force HTTPS in the final redirect authorization URIs set this setting to True

#### SOCIAL_AUTH_ALLOWED_REDIRECT_HOSTS
List of allowed URL redirects to, in most cases https://studio.example.com, where studio.example.com is your domain.

#### NO_MIGRATE_DB
When is enabled that the service won't apply migrations. It could be used for avoiding concurent migrations from different services

#### WAIT_FOR_MIGRATIONS
Should the service wait the migration until it finishes. Works with **NO_MIGRATE_DB=0**

### Github

#### GITHUB_APP_ID (required)
#### GITHUB_APP_CLIENT_ID (required)
#### GITHUB_APP_SECRET_KEY (required)
#### GITHUB_APP_PRIVATE_KEY_PEM (required)
#### GITHUB_URL
default: https://github.com
#### GITHUB_WEBHOOK_URL (required)
#### GITHUB_WEBHOOK_SECRET

### GitLab

#### GITLAB_CLIENT_ID
#### GITLAB_SECRET_KEY
#### GITLAB_URL
default: https://gitlab.com
#### GITLAB_WEBHOOK_URL
#### GITLAB_WEBHOOK_SECRET

### Bitbucket
#### BITBUCKET_CLIENT_ID
#### BITBUCKET_SECRET_KEY
#### BITBUCKET_API_URL
#### BITBUCKET_URL
#### BITBUCKET_WEBHOOK_URL

## Frontend

#### API_URL (required)
#### SCM_PROVIDERS (required)
default=github,gitlab,bitbucket

#### GITHUB_APP_NAME
#### GITHUB_URL
default: https://github.com
####  GITLAB_URL
default: https://gitlab.com
####  BITBUCKET_URL
default: https://bitbucket.org

#### MAX_VIEWS
default: 100
#### MAX_TEAMS
default: 10
