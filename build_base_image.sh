#!/bin/bash

docker build -t docker_runner_base:latest docker/base
docker tag docker_runner_base:latest hicder/docker_runner_base:latest
