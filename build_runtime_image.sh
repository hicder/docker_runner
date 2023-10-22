#!/bin/bash

set -eu

args=$(getopt -o '+hp:' -l 'help,name:' -- "$@")
eval set -- "$args"

set +e
read -r -d '' usage_str <<END
Usage:
  $0 [options...]

Entry-point for the runtime image build script.

Options:
  -h, --help               Help
  -p, --project            Name for this container
END
set -e

while :; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
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

echo "Buiding docker/$PROJECT"

user=$(id -un)
user_id=$(id -u)
group_id=$(id -g)
group=$(id -gn)

docker build --build-arg user=$user --build-arg user_id=$user_id --build-arg group=$group --build-arg group_id=$group_id -t hicder/"$PROJECT"_runtime:latest docker/$PROJECT
