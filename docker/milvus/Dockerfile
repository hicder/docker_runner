FROM hicder/docker_runner_base:latest

ARG TARGETARCH

RUN case "${TARGETARCH}" in \
      amd64) LLVM_ARCH=X64 ;; \
      arm64) LLVM_ARCH=ARM64 ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-23.1.0/LLVM-23.1.0-Linux-${LLVM_ARCH}.tar.xz -o /tmp/llvm.tar.xz \
    && mkdir -p /opt/llvm-23 \
    && tar -xJf /tmp/llvm.tar.xz --strip-components=1 -C /opt/llvm-23 \
    && rm /tmp/llvm.tar.xz

# Need to remove default gcc/g++ (and old clang) so only gcc-12/g++-12 remain
RUN apt remove -y gcc g++ build-essential cmake clang-20 llvm clangd-20 libabsl20260107 liburing-dev
RUN apt autoremove -y

# Install necessary packages to compile milvus
RUN apt update && apt install -y libopenblas-dev liblapack-dev pkg-config gcc-12 g++-12 libcrypt-dev libaio-dev direnv make libclang-21-dev
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 100
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 100

# Build liburing 2.15 from GitHub instead of using Ubuntu's liburing
RUN curl -L https://github.com/axboe/liburing/archive/refs/tags/liburing-2.15.tar.gz -o /tmp/liburing.tar.gz \
    && tar -xzf /tmp/liburing.tar.gz -C /tmp \
    && cd /tmp/liburing-liburing-2.15 \
    && ./configure --prefix=/usr --libdir=/usr/lib --libdevdir=/usr/lib --cc=gcc --cxx=g++ \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && rm -rf /tmp/liburing.tar.gz /tmp/liburing-liburing-2.15

ENV GO111MODULE=on
ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++
ENV CGO_LDFLAGS="-Wl,--no-as-needed -luring"

WORKDIR /
