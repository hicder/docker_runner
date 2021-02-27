#!/bin/bash

set -eu

args=$(getopt -o '+hj:r:i:' -l 'help,parallel_jobs:,repo:,image_tag:' -- "$@")
eval set -- "$args"

set +e
read -r -d '' usage_str <<END
Usage:
  $0 [options...]

Entry-point for the RocksDB-Cloud test script.

Options:
  -h, --help               Help
  -j, --parallel_jobs      Number of parallel jobs
  -r, --repo               Path to repositories
  -t, --image_tag          Base image tag
END
set -e

while :; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
          ;;
      -j|--parallel_jobs)
          PARALLEL_JOBS="$2"
          shift
          ;;
      -r|--repo)
          REPO="$2"
          shift
          ;;
      -i|--image_tag)
          TAG="$2"
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
echo "Run with $PARALLEL_JOBS jobs, repo $SRC_ROOT, tag $TAG" 
echo "Remaining is $@"

echo $EXTRA_DOCKER_RUN_ARGS

# Create build directory 
docker run -v $SRC_ROOT:/opt/src -w /opt/src -u $UID $EXTRA_DOCKER_RUN_ARGS --rm $TAG /bin/bash -c "mkdir -p build"

# Run the build in `build` directory
docker run -v $SRC_ROOT:/opt/src -w /opt/src/build -u $UID $EXTRA_DOCKER_RUN_ARGS --rm $TAG /bin/bash -c "$@"
