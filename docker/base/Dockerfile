FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update -y && \
    apt-get -qq upgrade -y && \
    apt-get -qq install -y apt-utils wget

RUN apt-get install -y gdb g++-10 build-essential software-properties-common git \
    curl libbz2-dev libcurl4-openssl-dev libgflags-dev libsnappy-dev zlib1g-dev \
    libssl-dev python2 libtbb-dev ccache sudo clang-14 clangd-14 python3 python3-pip ninja-build \
    libstdc++-10-dev libbison-dev libreadline-dev cmake

# This is to generate compile_commands.json for Makefile project
RUN pip3 install compiledb
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# ccache location
ENV CCACHE_DIR /opt/src/.cache

# By default, use clang for compilation
ENV CXX /usr/bin/clang++-14
ENV CC /usr/bin/clang-14

RUN ldconfig

# This is so that VSCode can open a Remote Development session to this container
RUN apt-get -y install openssh-server locales \
    && mkdir -p /var/run/sshd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && locale-gen en_US.UTF-8 \
    | cat >/dev/null

# Support golang
WORKDIR /tmp
RUN wget https://golang.org/dl/go1.19.2.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.19.2.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"

RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-14 100
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-14 100
RUN apt install -y bear

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

WORKDIR /
