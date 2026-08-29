#!/bin/bash

set -eu

_script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
. "$_script_dir/common.sh"

usage_str="Usage:
  $0 [options...]

Build the documentdb runtime image.

Options:
  -h, --help               Help
      --platform           Target platform (default: linux/<host-arch>)
"

PLATFORM=""

while [[ $# -gt 0 ]]; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
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

echo "Buiding docker/documentdb"

user=$(id -un)
user_id=$(id -u)
group_id=$(id -g)
group=$(id -gn)

docker_with_platform build --build-arg user=$user --build-arg user_id=$user_id --build-arg group=$group --build-arg group_id=$group_id -t hicder/documentdb_runtime:latest -f docker/documentdb/Dockerfile /home/hieu/code/documentdb
