#!/bin/bash

set -eu

_script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
. "$_script_dir/common.sh"

usage_str="Usage:
  $0 [options...]

Build base image

Options:
  -h, --help               Help
  -f, --force              Build without cache
      --platform           Target platform (default: linux/<host-arch>)
"

FORCE=0
PLATFORM=""

while [[ $# -gt 0 ]]; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
          ;;
      -f|--force)
          FORCE=1
          shift
          ;;
      --platform)
          PLATFORM="$2"
          shift 2
          ;;
      --platform=*)
          PLATFORM="${1#*=}"
          shift
          ;;
      --)
          shift
          break
          ;;
      -*)
          echo "Unknown option: $1" >&2
          echo "$usage_str" >&2
          exit 1
          ;;
      *)
          break
          ;;
  esac
done

resolve_platform

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

docker_with_platform build $NO_CACHE_ARGS --build-arg user=$user --build-arg user_id=$user_id --build-arg group=$group --build-arg group_id=$group_id -t docker_runner_base:latest docker/base
docker tag docker_runner_base:latest hicder/docker_runner_base:latest
