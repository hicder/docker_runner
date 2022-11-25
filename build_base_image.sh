#!/bin/bash

set -eu

args=$(getopt -o '+hf' -l 'help,force' -- "$@")
eval set -- "$args"

set +e
read -r -d '' usage_str <<END
Usage:
  $0 [options...]

Build base image

Options:
  -h, --help               Help
  -f, --force              Build without cache
END
set -e

FORCE=0

while :; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
          ;;
      -f|--force)
          FORCE=1
          ;;
      --)
          shift
          break
          ;;
  esac
  shift
done

NO_CACHE_ARGS="--no-cache"

if [ $FORCE -eq 1 ]; then
	echo 'Force rebuild'
else
	echo 'Use cache'
	NO_CACHE_ARGS=""
fi

user=$(id -un)
user_id=$(id -u)
group_id=$(id -g)
group=$(id -gn)

docker build $NO_CACHE_ARGS --build-arg user=$user --build-arg user_id=$user_id --build-arg group=$group --build-arg group_id=$group_id -t docker_runner_base:latest docker/base
docker tag docker_runner_base:latest hicder/docker_runner_base:latest
