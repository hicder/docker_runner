FROM hicder/docker_runner_base:latest

RUN apt install -y lld
RUN apt install -y clang-17 libc++-17-dev libc++abi-17-dev

RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-19 200
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-17 200
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-17 200

WORKDIR /
