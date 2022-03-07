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
errors_msg[GITHUB_WEBHOOK_URL]='Set GITHUB_WEBHOOK_URL, by default ${API_URL}/webhook/github-app/'
errors_msg[GITLAB_WEBHOOK_URL]='Set GITLAB_WEBHOOK_URL, by default ${API_URL}/webhook/gitlab/'
errors_msg[BITBUCKET_WEBHOOK_URL]='Set BITBUCKET_WEBHOOK_URL, by default ${API_URL}/webhook/bitbucket/'

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
  echo "  --hostname studio.example.com"
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
    [ -n "$STUDIO_HOSTNAME" ] && check_env_variable GITHUB_WEBHOOK_URL
    PROVIDERS+=("github")
  fi

  if [ -n "$GITLAB_CLIENT_ID" ]; then
    check_env_variable GITLAB_SECRET_KEY
    [ -n "$STUDIO_HOSTNAME" ] && check_env_variable GITLAB_WEBHOOK_URL
    PROVIDERS+=("gitlab")
  fi

  if [ -n "$BITBUCKET_CLIENT_ID" ]; then
    check_env_variable BITBUCKET_SECRET_KEY
    [ -n "$STUDIO_HOSTNAME" ] && check_env_variable BITBUCKET_WEBHOOK_URL
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
    --hostname)
        shift 1
        export STUDIO_HOSTNAME=$1
        export UI_URL=http://${STUDIO_HOSTNAME}
        export API_URL=http://${STUDIO_HOSTNAME}/api
        MANIFESTS+=(-f ./docker-compose/traefik.yaml)
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

if [ ${#env_errors[@]} -ne 0 ]; then
  ( IFS=$'\n'; echo "${env_errors[*]}" )
  echo
  echo "To see supported environment variables please check docker-compose/base.yaml"
  exit 1
fi

$EXEC ${MANIFESTS[@]} config $@ > docker-compose.yaml

echo "Application was configured"
echo "Launch it with "
echo "> docker-compose up"
