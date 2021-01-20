#!/bin/bash

export DVC_VIEWER_BACKEND_IMAGE=docker.iterative.ai/viewer_backend
export DVC_VIEWER_UI_IMAGE=docker.iterative.ai/viewer_ui
export DVC_VIEWER_RELEASE_VERSION=latest

EXEC="docker-compose --no-ansi"
MANIFESTS=(-f ./docker-compose/base.yaml)

RELEASED_VERSIONS=(
  latest
  v0.26.1
  v0.26.0
  v0.25.0
)

declare -a env_errors

usage () {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "OPTIONS:"
  echo "  --ascii"
  echo "  --no-postgres"
  echo "  --no-redis"
  echo "  --release-version v0.26.0"
  echo "  --hostname viewer.dvc.org"
}

print_supported_envs () {
  echo "Supported envs:"
  echo "  GITHUB_CLIENT_ID*"
  echo "  GITHUB_SECRET_KEY*"
  echo "  GITHUB_WEBHOOK_URL"
  echo "  GITHUB_WEBHOOK_SECRET"
  echo
  echo "  GITLAB_URL"
  echo "  GITLAB_CLIENT_ID**"
  echo "  GITLAB_SECRET_KEY**"
  echo "  GITLAB_WEBHOOK_URL"
  echo "  GITLAB_WEBHOOK_SECRET"
  echo
  echo "  BITBUCKET_CLIENT_ID"
  echo "  BITBUCKET_SECRET_KEY"
  echo "  BITBUCKET_WEBHOOK_URL"
  echo
  echo "  POSTGRES_URL"
  echo "  REDIS_URL"
  echo
  echo "*/** - required any of"
}

init_scm_providers() {
  declare -a PROVIDERS
  if [ -n "$GITHUB_CLIENT_ID" ]; then
    PROVIDERS+=("github")
  fi

  if [ -n "$GITLAB_CLIENT_ID" ]; then
    PROVIDERS+=("gitlab")
  fi

  if [ -n "$BITBUCKET_CLIENT_ID" ]; then
    PROVIDERS+=("bitbucket")
  fi

  if [ ${#PROVIDERS[@]} -eq 0 ]; then
    env_errors+=("MUST provide either GITHUB_CLIENT_ID, GITLAB_CLIENT_ID or BITBUCKET_CLIENT_ID env")
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
        export VIEWER_HOSTNAME=$1
        export UI_URL=http://${VIEWER_HOSTNAME}
        export API_URL=http://${VIEWER_HOSTNAME}/api
        MANIFESTS+=(-f ./docker-compose/traefik.yaml)
        shift 1
        ;;
    -h|--help)
      usage
      exit 0
      ;;
    --release-version)
      shift 1
      DVC_VIEWER_RELEASE_VERSION=$1
      if [[ ! ${RELEASED_VERSIONS[@]} =~ " $DVC_VIEWER_RELEASE_VERSION " ]]; then
        echo "There is no such released version"
        echo "Supported versions:"
        ( IFS=$'\n'; echo "${RELEASED_VERSIONS[*]}" )
        exit 1
      fi
      shift 1
      ;;
    --)
      shift
      ;;
    *)
      break
      ;;
  esac
done

init_scm_providers

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
  echo "more info: $0 --envs"
  exit 1
fi

$EXEC ${MANIFESTS[@]} config $@ > docker-compose.yaml

echo
echo "Application was configures"
echo "Launch with "
echo "> docker-compose up"
