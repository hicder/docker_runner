FROM hicder/docker_runner_base:latest

RUN curl -1sLf "https://raw.githubusercontent.com/redpanda-data/redpanda/dev/install-dependencies.sh" | bash

RUN ldconfig
ENV PATH="${PATH}:/opt/depot_tools"

WORKDIR /opt/depot_tools
RUN git config core.filemode false

WORKDIR /
