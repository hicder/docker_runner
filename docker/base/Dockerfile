FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get -qq update -y && \
    apt-get -qq upgrade -y && \
    apt-get -qq install -y apt-utils wget && \
    apt-get install -y software-properties-common gdb g++ build-essential git \
    curl libbz2-dev libcurl4-openssl-dev libgflags-dev libsnappy-dev zlib1g-dev \
    libssl-dev libtbb-dev ccache sudo clang-19 clangd-19 python3 python3-pip ninja-build \
    libstdc++-10-dev libbison-dev libreadline-dev cmake bear zsh fzf unzip openssh-server \
    locales meson flex bison liburing-dev pkg-config nodejs npm python3-venv ripgrep libresolv-wrapper

ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

# ccache location
ENV CCACHE_DIR /opt/src/.cache # Force linking libraries
RUN ldconfig

# This is so that VSCode can open a Remote Development session to this container
RUN apt-get -y install openssh-server locales \
    && mkdir -p /var/run/sshd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && locale-gen en_US.UTF-8 \
    | cat >/dev/null

# Install golang
WORKDIR /tmp
RUN wget https://golang.org/dl/go1.24.5.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.5.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"

RUN update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-19 100
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 10

# By default, use clang for compilation
ENV CXX /usr/bin/clang++
ENV CC /usr/bin/clang

# Install neovim 0.11.3 manually
WORKDIR /tmp
RUN wget https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.tar.gz
RUN tar -xzvf nvim-linux-x86_64.tar.gz
RUN cp -r nvim-linux-x86_64/bin/* /usr/local/bin
RUN cp -r nvim-linux-x86_64/share/* /usr/local/share
RUN cp -r nvim-linux-x86_64/lib/* /usr/local/lib

RUN deluser ubuntu || true

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

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="${PATH}:/home/${user}/.bun/bin"
RUN /home/${user}/.bun/bin/bun add -g opencode-ai || true

# Done - back to root
USER root

# Add $user as sudoer - we might need this down the road.
RUN usermod -aG sudo $user

WORKDIR /
