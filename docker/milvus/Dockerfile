FROM hicder/docker_runner_base:latest

RUN curl -1sLf "https://raw.githubusercontent.com/milvus-io/milvus/master/scripts/install_deps.sh" | bash
RUN apt install -y automake libtool m4
ENV GO111MODULE=on

WORKDIR /
