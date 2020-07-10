#!/bin/bash

export DVC_VIEWER_BACKEND_IMAGE=260760892802.dkr.ecr.us-east-2.amazonaws.com/dvc_viewer_backend_release
export DVC_VIEWER_UI_IMAGE=260760892802.dkr.ecr.us-east-2.amazonaws.com/dvc_viewer_ui_release
export DVC_VIEWER_RELEASE_VERSION=v0.7.0

EXEC="docker-compose --no-ansi"
MANIFESTS=(-f ./docker-compose/base.yaml)

RELEASED_VERSIONS=(
  latest
  v0.7.0
  v0.6.1
  v0.6.0
)

declare -a env_errors

usage () {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "OPTIONS:"
  echo "  --ascii"
  echo "  --no-postgres"
  echo "  --no-redis"
  echo "  --release-version v0.5.1"
}

print_supported_envs () {
  echo "Supported envs:"
  echo "  GITHUB_CLIENT_ID*"
  echo "  GITHUB_SECRET_KEY*"
  echo
  echo "  GITHUB_WEBHOOK_URL"
  echo "  GITHUB_WEBHOOK_SECRET"
  echo
  echo "  POSTGRES_URL"
  echo "  REDIS_URL"
  echo
  echo "* - required"
}

check_requirements() {
  if [ -z "$GITHUB_CLIENT_ID" ]; then
    env_errors+=("MUST provide GITHUB_CLIENT_ID env")
  fi

  if [ -z "$GITHUB_SECRET_KEY" ]; then
    env_errors+=("MUST provide GITHUB_SECRET_KEY env")
  fi
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

check_requirements

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

set -ex
$EXEC ${MANIFESTS[@]} up $@
