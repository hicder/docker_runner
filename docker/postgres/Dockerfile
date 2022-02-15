FROM hicder/docker_runner_base:latest

RUN apt install -y libreadline-dev flex bear ccls

# Prefer to use clang for clickhouse
ENV CXX g++-10
ENV CC gcc-10

WORKDIR /
