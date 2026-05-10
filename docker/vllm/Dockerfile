FROM rocm/vllm-dev:base AS dev

LABEL org.opencontainers.image.authors="hieu@opencode.ai"
LABEL org.opencontainers.image.description="Development environment for vLLM with ROCm"
LABEL org.opencontainers.image.source="https://github.com/hicder/docker_runner"

# Install development tools and SSH
RUN apt-get update -y && \
    apt-get install -y \
    # SSH for remote development
    openssh-server openssh-client \
    # Development tools
    git make cmake ninja-build gcc g++ clang \
    python3 python3-pip python3-venv python3-dev \
    curl wget unzip \
    libcurl4-openssl-dev libssl-dev \
    zlib1g-dev libbz2-dev pkg-config \
    gdb \
    # System tools
    vim zsh tmux jq \
    # Additional tools for vLLM building
    libjpeg-dev libsox-dev libsox-fmt-all sox \
    libfmt-dev libmsgpack-dev libsuitesparse-dev \
    liblzma-dev libpci-dev libopenmpi-dev \
    libgfortran5 \
    sqlite3 libsqlite3-dev \
    apt-transport-https ca-certificates \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# Install UV for Python package management
RUN curl -LsSf --retry 3 --retry-delay 5 https://astral.sh/uv/install.sh -o /tmp/uv-install.sh \
    && env UV_INSTALL_DIR="/usr/local/bin" sh /tmp/uv-install.sh \
    && rm -f /tmp/uv-install.sh \
    && uv --version

ENV UV_HTTP_TIMEOUT=500
ENV UV_INDEX_STRATEGY="unsafe-best-match"
ENV UV_LINK_MODE=copy

# Setup SSH for remote development
RUN mkdir -p /var/run/sshd && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    # Set locale
    locale-gen en_US.UTF-8 || true

RUN chmod 777 /etc/ssh/sshd_config
RUN ssh-keygen -A
RUN rm -f /run/nologin /etc/nologin

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8

# ccache location
ENV CCACHE_DIR=/opt/src/.cache

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

RUN echo "Setting up user: $user (UID: $user_id, GID: $group_id, Group: $group)"

# Create user with proper group setup
RUN if [ "$group" != "root" ]; then groupadd -g $group_id $group || true; fi && \
    # Ensure sudo group exists
    groupadd sudo || true && \
    useradd -m -c '' -g $group_id -N -u $user_id -s /bin/bash -d /home/$user $user || true && \
    # Add user to sudo group
    usermod -aG sudo $user || true && \
    # Enable passwordless sudo
    echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$user && \
    chmod 0440 /etc/sudoers.d/$user

# Install Go as root before switching to user
WORKDIR /tmp
RUN curl -O https://dl.google.com/go/go1.23.4.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz && \
    rm -f go1.23.4.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"

# Switch to user for final setup
USER $user

# Setup user environment
WORKDIR /home/$user
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || echo "ohmyzsh install failed, continuing"

# Install Rust
ENV HOME=/home/$user
ENV RUSTUP_HOME=$HOME/.rustup
ENV CARGO_HOME=$HOME/.cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y --profile minimal --default-toolchain none
RUN echo 'source $HOME/.cargo/env' >> $HOME/.zshrc
RUN echo 'source $HOME/.cargo/env' >> $HOME/.bashrc

# Add Go to user PATH in zshrc
RUN echo 'export PATH="${PATH}:/usr/local/go/bin"' >> $HOME/.zshrc

# Install Bun and opencode
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="${PATH}:/home/${user}/.bun/bin"
RUN bun add -g opencode-ai

# Configure git for the user
RUN git config --global user.email "$user@docker.local" && \
    git config --global user.name "Docker User"

# Switch back to root for final setup
USER root
WORKDIR /opt/src

# Ensure Python3 and pip are properly linked
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1

# Keep ROCm environment variables
ENV PATH=/opt/rocm/llvm/bin:/opt/rocm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV ROCM_PATH=/opt/rocm
ENV LD_LIBRARY_PATH=/opt/rocm/lib:/usr/local/lib
ENV PYTORCH_ROCM_ARCH=gfx90a;gfx942;gfx950;gfx1100;gfx1101;gfx1200;gfx1201;gfx1150;gfx1151
ENV AITER_ROCM_ARCH=gfx942;gfx950
ENV MORI_GPU_ARCHS=gfx942;gfx950
ENV HSA_NO_SCRATCH_RECLAIM=1
ENV VLLM_TARGET_DEVICE=rocm
ENV ROCM_HOME=/opt/rocm

# Setup pip cache directory
ENV PIP_CACHE_DIR=/opt/src/.cache/pip
