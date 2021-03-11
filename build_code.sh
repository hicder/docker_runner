#!/bin/bash

set -eu

args=$(getopt -o '+h:r:p:' -l 'help,repo:,project:' -- "$@")
eval set -- "$args"

set +e
read -r -d '' usage_str <<END
Usage:
  $0 [options...]

Entry-point for the RocksDB-Cloud test script.
Use env EXTRA_DOCKER_RUN_ARGS to add to docker command

Options:
  -h, --help               Help
  -r, --repo               Path to repositories
  -p, --project            Project name
END
set -e

while :; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
          ;;
      -r|--repo)
          REPO="$2"
          shift
          ;;
      -p|--project)
          PROJECT="$2"
          shift
          ;;
      --)
          shift
          break
          ;;
  esac
  shift
done

: "${EXTRA_DOCKER_RUN_ARGS:=}"

SRC_ROOT=$REPO
TAG=hicder/"$PROJECT"_runtime:latest
echo "Run repo $SRC_ROOT, tag $TAG" 
echo "Remaining is $@"

echo $EXTRA_DOCKER_RUN_ARGS

# Run the build in `build` directory
docker run -v $SRC_ROOT:/opt/src -w /opt/src -u $UID $EXTRA_DOCKER_RUN_ARGS --rm $TAG /bin/bash -c "$@"
