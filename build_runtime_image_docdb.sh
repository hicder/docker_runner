#!/bin/bash

set -eu

echo "Buiding docker/documentdb"

user=$(id -un)
user_id=$(id -u)
group_id=$(id -g)
group=$(id -gn)

docker build --build-arg user=$user --build-arg user_id=$user_id --build-arg group=$group --build-arg group_id=$group_id -t hicder/documentdb_runtime:latest -f docker/documentdb/Dockerfile /home/hieu/code/documentdb
