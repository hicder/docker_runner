FROM ubuntu:20.04

ARG TARGETPLATFORM

RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-transport-https \
    autoconf \
    bison \
    ca-certificates \
    clang-10 \
    cmake \
    curl \
    flex \
    g++ \
    git \
    gnupg2 \
    libncurses-dev \
    libtinfo-dev \
    llvm \
    lsof \
    make \
    netbase \
    openjdk-8-jre \
    openssh-client \
    patchelf \
    python-is-python3 \
    python3 \
    python3.8-venv \
    unzip \
    zip \
 && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 100 \
    --slave /usr/bin/clang++ clang++ /usr/bin/clang++-10 \
 && apt-get clean

# We need a newer version of cmake.
#
# NOTE: When upgrading cmake, bump the rebuild counters in
# c-deps/*-rebuild to force recreating the makefiles. This prevents
# strange build errors caused by those makefiles depending on the
# installed version of cmake.
RUN case ${TARGETPLATFORM} in \
    "linux/amd64") ARCH=x86_64; SHASUM=97bf730372f9900b2dfb9206fccbcf92f5c7f3b502148b832e77451aa0f9e0e6 ;; \
    "linux/arm64") ARCH=aarch64; SHASUM=77620f99e9d5f39cf4a49294c6a68c89a978ecef144894618974b9958efe3c2a ;; \
  esac \
 && curl -fsSL "https://github.com/Kitware/CMake/releases/download/v3.20.3/cmake-3.20.3-linux-$ARCH.tar.gz" -o cmake.tar.gz \
 && echo "$SHASUM cmake.tar.gz" | sha256sum -c - \
 && tar --strip-components=1 -C /usr -xzf cmake.tar.gz \
 && rm cmake.tar.gz

# git - Upgrade to a more modern version
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install dh-autoreconf libcurl4-gnutls-dev libexpat1-dev gettext libz-dev libssl-dev -y && \
    apt-get clean && \
    curl -fsSL https://github.com/git/git/archive/v2.29.2.zip -o "git-2.29.2.zip" && \
    unzip "git-2.29.2.zip" && \
    cd git-2.29.2 && \
    make configure && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf git-2.29.2.zip git-2.29.2

RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && echo 'deb https://packages.cloud.google.com/apt cloud-sdk main' | tee /etc/apt/sources.list.d/gcloud.list \
 && curl -fsLS https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | apt-key add - \
 && echo "deb https://packages.microsoft.com/repos/azure-cli/ focal main" > /etc/apt/sources.list.d/azure-cli.list \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    azure-cli \
    google-cloud-sdk \
    google-cloud-cli-gke-gcloud-auth-plugin \
    && apt-get clean

RUN apt-get purge -y \
    apt-transport-https \
    flex \
    gettext \
 && apt-get autoremove -y

# This is so that VSCode can open a Remote Development session to this container
RUN apt-get -y install openssh-server locales zsh sudo libc6-dev \
    && mkdir -p /var/run/sshd \
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && locale-gen en_US.UTF-8 \
    | cat >/dev/null

# awscli - roachtests
# NB: we don't use apt-get because we need an up to date version of awscli
RUN case ${TARGETPLATFORM} in \
    "linux/amd64") ARCH=x86_64; SHASUM=e679933eec90b0e5a75d485be6c2fae0f89a3f9ccdcb1748be69f8f456e9a85f ;; \
    "linux/arm64") ARCH=aarch64; SHASUM=7d6460f795712ebdac7e3c60d4800dde682d136d909810402aac164f2789b860 ;; \
  esac && \
 curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-$ARCH-2.13.9.zip" -o "awscliv2.zip" && \
 echo "$SHASUM awscliv2.zip" | sha256sum -c - && \
 unzip awscliv2.zip && \
 ./aws/install && \
 rm -rf aws awscliv2.zip

# Install golang
WORKDIR /tmp
RUN wget https://golang.org/dl/go1.24.5.linux-amd64.tar.gz
RUN rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.5.linux-amd64.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"

# Install Bazelisk as Bazel.
# NOTE: you should keep this in sync with build/packer/teamcity-agent.sh and
# build/bootstrap/bootstrap-debian.sh -- if an update is necessary here, it's probably
# necessary in the agent as well.
RUN case ${TARGETPLATFORM} in \
    "linux/amd64") ARCH=amd64; SHASUM=4cb534c52cdd47a6223d4596d530e7c9c785438ab3b0a49ff347e991c210b2cd ;; \
    "linux/arm64") ARCH=arm64; SHASUM=c1de6860dd4f8d5e2ec270097bd46d6a211b971a0b8b38559784bd051ea950a1 ;; \
  esac \
 && curl -fsSL "https://github.com/bazelbuild/bazelisk/releases/download/v1.10.1/bazelisk-linux-$ARCH" > /tmp/bazelisk \
 && echo "$SHASUM /tmp/bazelisk" | sha256sum -c - \
 && chmod +x /tmp/bazelisk \
 && mv /tmp/bazelisk /usr/bin/bazel

# Replace the nm command with LLVM's version, llvm-nm, which knows how to read
# binaries build for platforms others than Linux.
RUN ln -sf /usr/bin/llvm-nm /usr/bin/nm

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

USER root
WORKDIR /