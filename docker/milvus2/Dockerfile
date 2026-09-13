FROM ubuntu:22.04
ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

# Official milvus 2.6 ubuntu22.04 builder apt packages, plus the extra
# development tools from docker/milvus. gcc-12 is the official compiler.
RUN apt-get -qq update -y && \
    apt-get -qq upgrade -y && \
    apt-get -qq install -y apt-utils && \
    apt-get install -y \
    wget curl ca-certificates gnupg2 \
    g++ gcc gfortran git make ccache libssl-dev zlib1g-dev zip unzip \
    clang-format-12 clang-tidy-12 lcov libtool m4 autoconf automake python3 python3-pip \
    pkg-config uuid-dev libaio-dev libopenblas-dev libgoogle-perftools-dev \
    gcc-12 g++-12 \
    software-properties-common gdb gdbserver ninja-build python3-venv \
    libbz2-dev libcurl4-openssl-dev libgflags-dev libsnappy-dev \
    libtbb-dev sudo libbison-dev libreadline-dev bear zsh fzf openssh-server \
    locales meson flex bison nodejs npm ripgrep libresolv-wrapper \
    nano jq liblapack-dev libcrypt-dev direnv tzdata \
    && ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && echo "Etc/UTC" > /etc/timezone

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# ccache location
ENV CCACHE_DIR /opt/src/.cache
RUN ldconfig

# This is so that VSCode can open a Remote Development session to this container
RUN apt-get -y install openssh-server locales \
    && mkdir -p /var/run/sshd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && locale-gen en_US.UTF-8 \
    | cat >/dev/null

# Official ubuntu22.04 builder ships cmake 3.31.8
RUN case "${TARGETARCH}" in \
      amd64) CMAKE_ARCH=x86_64 ;; \
      arm64) CMAKE_ARCH=aarch64 ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && wget -qO- "https://cmake.org/files/v3.31/cmake-3.31.8-linux-${CMAKE_ARCH}.tar.gz" \
    | tar --strip-components=1 -xz -C /usr/local

RUN pip3 install conan==1.64.1

# Install golang (same version as the official ubuntu22.04 builder)
ENV GOPATH /go
ENV GOROOT /usr/local/go
ENV GO111MODULE on
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH
RUN mkdir -p /usr/local/go && \
    wget -qO- "https://go.dev/dl/go1.25.8.linux-${TARGETARCH}.tar.gz" \
      | tar --strip-components=1 -xz -C /usr/local/go && \
    mkdir -p "$GOPATH/src" "$GOPATH/bin"

RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-12 100
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100
RUN update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-12 100
RUN update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-12 100
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# Official ubuntu22.04 builder uses gcc-12
ENV CC=/usr/bin/gcc
ENV CXX=/usr/bin/g++

# Install neovim 0.11.3 manually
WORKDIR /tmp
RUN case "${TARGETARCH}" in \
      amd64) NVIM_ARCH=x86_64 ;; \
      arm64) NVIM_ARCH=arm64 ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && wget https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-${NVIM_ARCH}.tar.gz \
 && tar -xzvf nvim-linux-${NVIM_ARCH}.tar.gz \
 && cp -r nvim-linux-${NVIM_ARCH}/bin/* /usr/local/bin \
 && cp -r nvim-linux-${NVIM_ARCH}/share/* /usr/local/share \
 && cp -r nvim-linux-${NVIM_ARCH}/lib/* /usr/local/lib \
 && rm -rf nvim-linux-${NVIM_ARCH} nvim-linux-${NVIM_ARCH}.tar.gz

# LLVM 23 (clangd / libclang). Not on PATH as clang so gcc stays the compiler.
RUN case "${TARGETARCH}" in \
      amd64) LLVM_ARCH=X64 ;; \
      arm64) LLVM_ARCH=ARM64 ;; \
      *) echo "unsupported TARGETARCH: ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
    && curl -L https://github.com/llvm/llvm-project/releases/download/llvmorg-23.1.0/LLVM-23.1.0-Linux-${LLVM_ARCH}.tar.xz -o /tmp/llvm.tar.xz \
    && mkdir -p /opt/llvm-23 \
    && tar -xJf /tmp/llvm.tar.xz --strip-components=1 -C /opt/llvm-23 \
    && rm /tmp/llvm.tar.xz
RUN update-alternatives --install /usr/bin/clangd clangd /opt/llvm-23/bin/clangd 100
ENV LIBCLANG_PATH=/opt/llvm-23/lib

# Build liburing 2.15 from GitHub instead of using Ubuntu's liburing
RUN curl -L https://github.com/axboe/liburing/archive/refs/tags/liburing-2.15.tar.gz -o /tmp/liburing.tar.gz \
    && tar -xzf /tmp/liburing.tar.gz -C /tmp \
    && cd /tmp/liburing-liburing-2.15 \
    && ./configure --prefix=/usr --libdir=/usr/lib --libdevdir=/usr/lib --cc=gcc --cxx=g++ \
    && make -j$(nproc) \
    && make install \
    && ldconfig \
    && rm -rf /tmp/liburing.tar.gz /tmp/liburing-liburing-2.15

ENV CGO_LDFLAGS="-Wl,--no-as-needed -luring"
ENV CMAKE_EXTRA_ARGS="-DCMAKE_EXE_LINKER_FLAGS=-Wl,--no-as-needed,-luring"

# Add current user
ARG group_id
ARG group
ARG user_id
ARG user

RUN echo "$user"
RUN echo "$user_id"
RUN echo "$group"
RUN echo "$group_id"

RUN groupadd -g $group_id $group || true
RUN useradd -m -c '' -g $group_id -N -u $user_id -s /bin/bash -d /home/$user $user || true

USER $user

WORKDIR /home/$user
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install rust
ENV HOME /home/$user
ENV RUSTUP_HOME $HOME/.rustup
ENV CARGO_HOME $HOME/.cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain nightly
RUN echo 'source $HOME/.cargo/env' >> $HOME/.zshrc

RUN mkdir -p /home/$user/.config || true
WORKDIR /home/$user/.config
RUN git clone --branch container https://github.com/hicder/lazyvim.git nvim

RUN mkdir -p /home/$user/code || true
WORKDIR /home/$user/code
RUN git clone --branch container https://github.com/hicder/dotfiles.git

WORKDIR /home/$user/code/dotfiles
RUN ./install.sh

# Install opencode
RUN curl -fsSL https://opencode.ai/install | bash

# Install claude code
RUN curl -fsSL https://claude.ai/install.sh | bash

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
RUN echo '. $HOME/.nvm/nvm.sh' >> $HOME/.zshrc
RUN echo '. $HOME/.nvm/nvm.sh' >> $HOME/.bashrc

# Add /usr/local/go/bin/ to PATH for this user
RUN echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.zsh
RUN echo 'export PATH=$PATH:/usr/local/go/bin' >> $HOME/.bashrc

# Done - back to root
USER root

# Add $user as sudoer - we might need this down the road.
RUN usermod -aG sudo $user
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

WORKDIR /
