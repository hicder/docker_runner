FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update -y && \
    apt-get -qq upgrade -y && \
    apt-get -qq install -y apt-utils wget

# Add clang-12 repository
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -
RUN add-apt-repository 'deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-12 main'
RUN apt-get update

RUN apt-get install -y gdb g++-10 build-essential software-properties-common git \
    curl libbz2-dev libcurl4-openssl-dev libgflags-dev libsnappy-dev zlib1g-dev \
    libssl-dev python libtbb-dev ccache sudo clang-12 clangd-12 python3 python3-pip ninja-build

# This is to generate compile_commands.json for Makefile project
RUN pip3 install compiledb
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# ccache location
ENV CCACHE_DIR /opt/src/.ccache

# By default, use gcc 10
ENV CXX /usr/bin/g++-10
ENV CC /usr/bin/gcc-10

# Download prebuilt cmake 3.19
RUN mkdir -p /ax-install
WORKDIR /ax-install
RUN curl -JLO https://cmake.org/files/v3.19/cmake-3.19.0-Linux-x86_64.tar.gz
WORKDIR /usr/local
RUN tar xfz /ax-install/cmake-3.19.0-Linux-x86_64.tar.gz --strip-components=1

RUN ldconfig

# This is so that VSCode can open a Remote Development session to this container
RUN apt-get -y install openssh-server locales \
    && mkdir -p /var/run/sshd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && locale-gen en_US.UTF-8 \
    | cat >/dev/null

WORKDIR /
