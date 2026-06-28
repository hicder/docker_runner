FROM hicder/docker_runner_base:latest

RUN curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.8/LLVM-22.1.8-Linux-X64.tar.xz -o /tmp/llvm.tar.xz \
    && mkdir -p /opt/llvm-22 \
    && tar -xJf /tmp/llvm.tar.xz --strip-components=1 -C /opt/llvm-22 \
    && rm /tmp/llvm.tar.xz

# Need to remove old versions of gcc/clang before installing new ones
RUN apt remove -y gcc cmake clang-20 llvm clangd-20 libabsl20260107
RUN apt autoremove -y

# Install necessary packages to compile milvus
RUN apt update && apt install -y libopenblas-dev liblapack-dev pkg-config gcc-12 g++-12 libcrypt-dev libaio-dev direnv
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 100
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 100
ENV GO111MODULE=on

WORKDIR /
