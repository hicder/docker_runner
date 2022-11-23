FROM hicder/docker_runner_base:latest

RUN apt install -y dpdk libdpdk-dev

RUN curl -1sLf "https://raw.githubusercontent.com/redpanda-data/redpanda/dev/install-dependencies.sh" | bash
RUN ldconfig

WORKDIR /
