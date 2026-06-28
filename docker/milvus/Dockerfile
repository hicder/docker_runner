FROM hicder/docker_runner_base:latest

RUN apt update
# Need to remove old versions of gcc/clang before installing new ones
RUN apt remove -y gcc cmake clang-20 llvm clangd-20 libabsl20260107
RUN apt autoremove -y
RUN apt install -y libopenblas-dev liblapack-dev pkg-config gcc-12 g++-12 libcrypt-dev libaio-dev
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 100
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 100
ENV GO111MODULE=on

WORKDIR /
