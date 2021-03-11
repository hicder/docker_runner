#!/bin/bash

set -eu

args=$(getopt -o '+hn:' -l 'help,name:' -- "$@")
eval set -- "$args"

set +e
read -r -d '' usage_str <<END
Usage:
  $0 [options...]

Entry-point for the RocksDB-Cloud test script.

Options:
  -h, --help               Help
  -n, --name               Name for this container
END
set -e

while :; do
  case "$1" in
      -h|--help)
          echo "$usage_str"
          exit 0
          ;;
      -n|--name)
          NAME="$2"
          shift
          ;;
      --)
          shift
          break
          ;;
  esac
  shift
done

echo "Buiding docker/$NAME"
docker build -t hicder/"$NAME"_runtime:latest docker/$NAME
