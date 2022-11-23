#!/bin/bash

user=$(id -un)
user_id=$(id -u)
group_id=$(id -g)
group=$(id -gn)

docker build --build-arg user=$user --build-arg user_id=$user_id --build-arg group=$group --build-arg group_id=$group_id -t docker_runner_base:latest docker/base
docker tag docker_runner_base:latest hicder/docker_runner_base:latest
