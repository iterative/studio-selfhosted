#!/bin/bash

export DVC_VIEWER_BACKEND_IMAGE=260760892802.dkr.ecr.us-east-2.amazonaws.com/dvc_viewer_backend_release
export DVC_VIEWER_UI_IMAGE=260760892802.dkr.ecr.us-east-2.amazonaws.com/dvc_viewer_ui_release
export DVC_VIEWER_RELEASE_VERSION=v0.5.1

EXEC="docker-compose --no-ansi"
MANIFESTS=(-f ./docker-compose/base.yaml)

RELEASED_VERSIONS=(
  v0.5.1
)

usage () {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "OPTIONS:"
  echo "  --ascii"
  echo "  --no-postgres"
  echo "  --no-redis"
  echo "  --release-version v0.5.1"
}

while [ $# -ne 0 ]; do
  case $1 in
    --ascii)
      EXEC="docker-compose"
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
    --help)
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


if [ "$NO_POSTGRES" != "1" ]; then
  MANIFESTS+=(-f ./docker-compose/postgres.yaml)
fi

if [ "$NO_REDIS" != "1" ]; then
  MANIFESTS+=(-f ./docker-compose/redis.yaml)
fi

set -ex
$EXEC ${MANIFESTS[@]} up $@
