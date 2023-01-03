#!/usr/bin/env bash

if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
  echo "ERROR: unsupported bash version, 4+ required"
  exit
fi

export STUDIO_BACKEND_IMAGE=docker.iterative.ai/viewer_backend
export STUDIO_UI_IMAGE=docker.iterative.ai/viewer_ui
export STUDIO_RELEASE_VERSION=latest

EXEC="docker-compose --ansi never"
MANIFESTS=(-f ./docker-compose/base.yaml)

declare -a env_errors
declare -A errors_msg

usage () {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "OPTIONS:"
  echo "  --envs"
  echo "  --env-file file"
  echo "  --ascii"
  echo "  --no-minio"
  echo "  --no-postgres"
  echo "  --no-redis"
  echo "  --url http://studio.example.com"
  echo "  --tls-cert-file server.crt  (works only with --url)"
  echo "  --tls-key-file server.key  (works only with --url)"
  echo "  --ui-image url"
  echo "  --backend-image url"
}


load_env() {
  if [ -f "$ENV_FILE" ]; then
    set -o allexport
    source $ENV_FILE
    set +o allexport
  fi
}

print_supported_envs () {
  echo "To see supported environment variables please check docker-compose/base.yaml"
}

check_env_variable() {
  eval v='$'$1
  if [ -z "$v" ]; then
    err=${errors_msg["$1"]:-"Missed $1"}
    env_errors+=("$err")
  fi
}

init_scm_providers() {
  declare -a PROVIDERS
  if [ -n "$GITHUB_APP_CLIENT_ID" ]; then
    check_env_variable GITHUB_APP_ID
    check_env_variable GITHUB_APP_SECRET_KEY
    check_env_variable GITHUB_APP_PRIVATE_KEY_PEM
    PROVIDERS+=("github")
  fi

  if [ -n "$GITLAB_CLIENT_ID" ]; then
    check_env_variable GITLAB_SECRET_KEY
    PROVIDERS+=("gitlab")
  fi

  if [ -n "$BITBUCKET_CLIENT_ID" ]; then
    check_env_variable BITBUCKET_SECRET_KEY
    PROVIDERS+=("bitbucket")
  fi

  if [ ${#PROVIDERS[@]} -eq 0 ]; then
    env_errors+=("MUST provide either GITHUB_APP_CLIENT_ID, GITLAB_CLIENT_ID or BITBUCKET_CLIENT_ID env")
  fi
  export SCM_PROVIDERS=`IFS=,; echo "${PROVIDERS[*]}"`
}

while [ $# -ne 0 ]; do
  case $1 in
    --ascii)
      EXEC="docker-compose"
      shift 1
      ;;
    --envs)
      print_supported_envs
      exit 0
      ;;
    --env-file)
      shift 1
      ENV_FILE=$1
      if [ -z "$ENV_FILE" ]; then
        echo "Point the path to the file"
        exit 1
      fi
      shift 1
      ;;
    --tls-ca-directory)
      shift 1
      export TLS_CA_DIRECTORY=$1
      shift 1
      ;;
    --tls-cert-file)
      shift 1
      export TLS_CERT_FILE=$1
      shift 1
      ;;
    --tls-key-file)
      shift 1
      export TLS_KEY_FILE=$1
      shift 1
      ;;
    --no-minio)
      NO_MINIO=1
      shift 1
      ;;
    --no-postgres)
      NO_POSTGRES=1
      shift 1
      ;;
    --no-redis)
      NO_REDIS=1
      shift 1
      ;;
    --url)
        shift 1
        export STUDIO_URL=$1
        export UI_URL=${STUDIO_URL}
        export API_URL=${STUDIO_URL}/api
        export BLOBVAULT_ENDPOINT_URL_FE=${STUDIO_URL}/minio
        export STUDIO_HOSTNAME=$(echo ${STUDIO_URL} | awk -F[/:] '{print $4}')
        # setting webhook urls
        export GITHUB_WEBHOOK_URL=${STUDIO_HOSTNAME}/webhook/github/
        export GITLAB_WEBHOOK_URL=${STUDIO_HOSTNAME}/webhook/gitlab/
        export BITBUCKET_WEBHOOK_URL=${STUDIO_HOSTNAME}/webhook/bitbucket/
        schema=$(echo ${STUDIO_URL} | awk -F: '{print $1}')
        if [ "$schema" = "https" ]; then
          export SOCIAL_AUTH_REDIRECT_IS_HTTPS=True
        fi
        shift 1
        ;;
    --backend-image)
      shift 1
      export STUDIO_BACKEND_IMAGE=$1
      export STUDIO_RELEASE_VERSION=latest
      shift 1
      ;;
    --ui-image)
      shift 1
      export STUDIO_UI_IMAGE=$1
      export STUDIO_RELEASE_VERSION=latest
      shift 1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      ;;
    *)
      break
      ;;
  esac
done

load_env
init_scm_providers

if [ "$NO_MINIO" != "1" ]; then
  MANIFESTS+=(-f ./docker-compose/minio.yaml)
else
  export ENABLE_BLOBVAULT="False"
  echo "$ENABLE_BLOBVAULT"
fi

if [ "$NO_POSTGRES" != "1" ]; then
  MANIFESTS+=(-f ./docker-compose/postgres.yaml)
else
  if [ -z "$POSTGRES_URL" ]; then
    env_errors+=("MUST provide POSTGRES_URL env")
  fi
fi

if [ "$NO_REDIS" != "1" ]; then
  MANIFESTS+=(-f ./docker-compose/redis.yaml)
else
  if [ -z "$REDIS_URL" ]; then
    env_errors+=("MUST provide REDIS_URL env")
  fi
fi

if [ -n "$STUDIO_HOSTNAME" ]; then
  MANIFESTS+=(-f ./docker-compose/traefik.yaml)

  if [ -n "$TLS_KEY_FILE" -a -n "$TLS_CERT_FILE" ]; then
    MANIFESTS+=(-f ./docker-compose/traefik_https.yaml)
  fi
fi

if [ -n "$TLS_CA_DIRECTORY" ]; then
  MANIFESTS+=(-f ./docker-compose/ca.yaml)
fi

if [ ${#env_errors[@]} -ne 0 ]; then
  ( IFS=$'\n'; echo "${env_errors[*]}" )
  echo
  echo "To see supported environment variables, please check docker-compose/base.yaml"
  exit 1
fi

$EXEC ${MANIFESTS[@]} config $@ > docker-compose.yaml

echo "Application was configured"
echo "Launch it with "
echo "> docker-compose up"
