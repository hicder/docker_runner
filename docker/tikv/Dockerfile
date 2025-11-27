FROM quay.io/rockylinux/rockylinux:8.10.20240529-ubi AS builder
LABEL org.opencontainers.image.authors="wuhui.zuo@pingcap.com"
LABEL org.opencontainers.image.description="binary builder for TiKV"
LABEL org.opencontainers.image.source="https://github.com/PingCAP-QE/artifacts"

# install packages for TiKV building
RUN --mount=type=cache,target=/var/cache/dnf \
    dnf upgrade-minimal -y && \
    dnf --enablerepo=powertools install -y \
    git findutils gcc gcc-c++ make cmake curl dwz openssl-devel perl python3  \
    libstdc++-static

# install protoc
ARG PROTOBUF_VER=v3.15.8
RUN FILE=$([ "$(arch)" = "aarch64" ] && echo "protoc-${PROTOBUF_VER#?}-linux-aarch_64.zip" || echo "protoc-${PROTOBUF_VER#?}-linux-$(arch).zip"); \
    curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/${PROTOBUF_VER}/${FILE}" && unzip "$FILE" -d /usr/local/ && rm -f "$FILE"

########### stage: non-root-builder
FROM builder AS non-root-builder
RUN dnf install -y sudo && \
    useradd builder --create-home --shell=/bin/bash --uid=1000 --user-group && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder

########### stage: Final image with SSH and development tools
FROM quay.io/rockylinux/rockylinux:8.10.20240528-ubi

# Install SSH server and development tools
RUN --mount=type=cache,target=/var/cache/dnf \
    dnf upgrade-minimal -y && \
    dnf install -y \
    # SSH for remote development
    openssh-server openssh-clients \
    # Development tools
    git make cmake gcc gcc-c++ clang clang-devel \
    python3 python3-pip npm \
    curl wget unzip zsh \
    libcurl-devel bzip2-devel zlib-devel openssl-devel \
    gdb pkg-config \
    perl python3 \
    # System tools
    vim-enhanced findutils which diffutils && \
    # Enable powertools repo for additional packages
    dnf --enablerepo=powertools install -y perl-Scalar-List-Utils perl-Getopt-Long perl-Time-HiRes sudo && \
    # Enable sudo for development
    mkdir -p /etc/sudoers.d && \
    echo '%wheel ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/wheel && \
    echo 'Defaults !env_reset' >> /etc/sudoers.d/development && \
    chmod 0440 /etc/sudoers.d/wheel

# Install protoc
ARG PROTOBUF_VER=v3.15.8
RUN FILE=$([ "$(arch)" = "aarch64" ] && echo "protoc-${PROTOBUF_VER#?}-linux-aarch_64.zip" || echo "protoc-${PROTOBUF_VER#?}-linux-$(arch).zip"); \
    curl -LO "https://github.com/protocolbuffers/protobuf/releases/download/${PROTOBUF_VER}/${FILE}" && unzip "$FILE" -d /usr/local/ && rm -f "$FILE"

# Switch to user context for Rust installation
# Install golang
WORKDIR /tmp
RUN curl -O https://dl.google.com/go/go1.25.4.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.25.4.linux-amd64.tar.gz && \
    rm -f go1.23.4.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"

# Setup SSH for remote development
RUN mkdir -p /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    # Set locale
    localedef -i en_US -f UTF-8 en_US.UTF-8 || true
RUN chmod 777 /etc/ssh/sshd_config
RUN ssh-keygen -A
RUN rm -f /run/nologin /etc/nologin

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8

# ccache location
ENV CCACHE_DIR /opt/src/.cache

# Install neovim
RUN mkdir -p /opt/bin
WORKDIR /opt/bin
RUN wget -q https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz && \
    tar xzvf nvim-linux-x86_64.tar.gz && \
    rm -f nvim-linux-x86_64.tar.gz

# Add current user (for docker_runner compatibility)
ARG group_id
ARG group
ARG user_id
ARG user

RUN echo "$user"
RUN echo "$user_id"
RUN echo "$group"
RUN echo "$group_id"

# Create user using Rocky Linux commands
RUN if [ "$group" != "root" ]; then groupadd -g $group_id $group || true; fi && \
    # Ensure wheel group exists for sudo access
    groupadd wheel || true && \
    useradd -m -c '' -g $group_id -N -u $user_id -s /bin/bash -d /home/$user $user || true && \
    # Add user to wheel group for sudo access
    usermod -aG wheel $user || true

# Switch to user for final setup
USER $user

# Setup user environment
WORKDIR /home/$user
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || echo "ohmyzsh install failed, continuing"

# Ensure Rust environment is available
ENV HOME /home/$user
ENV RUSTUP_HOME $HOME/.rustup
ENV CARGO_HOME $HOME/.cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain none
RUN echo 'source $HOME/.cargo/env' >> $HOME/.zshrc

RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="${PATH}:/home/${user}/.bun/bin"
RUN bun add -g opencode-ai

# Switch back to root for final setup
USER root
WORKDIR /opt/src
