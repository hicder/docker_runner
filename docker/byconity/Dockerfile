FROM hicder/docker_runner_base:latest

ARG user

WORKDIR /tmp
ARG FDB_VERSION=7.1.27
RUN wget -qO foundationdb-clients.deb https://github.com/apple/foundationdb/releases/download/${FDB_VERSION}/foundationdb-clients_${FDB_VERSION}-1_amd64.deb
RUN dpkg -i foundationdb-clients.deb && rm foundationdb-clients.deb
RUN apt-get install -y automake binutils-dev bison byacc ccache flex libiberty-dev libtool maven zip python3 python-is-python3 \
        make cmake gcc g++ default-jdk git patch lld bzip2 \
        wget unzip curl vim tree net-tools openssh-client xz-utils \
        openssh-server mold zsh ninja-build


RUN add-apt-repository 'deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-11 main'
RUN apt-get install -y clang-11
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-11 120
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-11 120

USER $user

WORKDIR /
