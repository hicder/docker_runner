#!/bin/bash

set -eu

_script_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=common.sh
. "$_script_dir/common.sh"

usage_str="Usage:
  $0 [options...]

Entry-point for the runtime image build script.

Options:
  -h, --help               Help
  -p, --project            Name for this container
  -r, --repo               Path to the repository
  -f, --force              Force rebuild without Docker cache
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
      -p|--project)
          PROJECT="$2"
          shift 2
          ;;
      --project=*)
          PROJECT="${1#*=}"
          shift
          ;;
      -r|--repo)
          REPO="$2"
          shift 2
          ;;
      --repo=*)
          REPO="${1#*=}"
          shift
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

echo "Buiding docker/$PROJECT"
echo "Repo is $REPO"

user=$(id -un)
user_id=$(id -u)
group_id=$(id -g)
group=$(id -gn)

no_cache=""
if [ "${FORCE:-0}" = "1" ]; then
  echo "Force mode enabled -- disabling Docker cache"
  no_cache="--no-cache"
fi

docker_with_platform build $no_cache --build-arg user=$user --build-arg user_id=$user_id --build-arg group=$group --build-arg group_id=$group_id -t hicder/"$PROJECT"_runtime:latest -f docker/$PROJECT/Dockerfile $REPO
