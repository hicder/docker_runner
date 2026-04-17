FROM hicder/docker_runner_base:latest

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    llvm \
    llvm-dev \
    libllvm-ocaml-dev \
    protobuf-compiler \
    libprotobuf-dev \
    libprotoc-dev \
    libgtest-dev \
    libgmock-dev \
    libxml2-dev \
    libicu-dev \
    libedit-dev \
    libzstd-dev \
    liblz4-dev \
    libxxhash-dev \
    bison \
    flex \
    libre2-dev \
    libssl-dev \
    libopenblas-dev \
    libabsl-dev \
    && rm -rf /var/lib/apt/lists/*

# Protobuf cmake config is in /usr/lib/cmake/protobuf - link to vespa-deps
RUN mkdir -p /opt/vespa-deps/lib/cmake && \
    ln -sf /usr/lib/x86_64-linux-gnu/cmake/protobuf /opt/vespa-deps/lib/cmake/protobuf && \
    ln -sf /usr/include/google /opt/vespa-deps/include/google && \
    ln -sf /usr/lib/x86_64-linux-gnu/libprotobuf*.so* /opt/vespa-deps/lib/ 2>/dev/null || true

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install clangd 22.1.0
RUN wget -O /tmp/clangd.zip https://github.com/clangd/clangd/releases/download/22.1.0/clangd-linux-22.1.0.zip && \
    unzip -o /tmp/clangd.zip -d /usr/local && \
    mv /usr/local/clangd_22.1.0/bin/clangd /usr/local/bin/clangd && \
    mv /usr/local/clangd_22.1.0/lib/clang /usr/local/lib/ 2>/dev/null || true && \
    rm -rf /usr/local/clangd_22.1.0 /tmp/clangd.zip

WORKDIR /
