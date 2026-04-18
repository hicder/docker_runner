FROM hicder/docker_runner_base:latest

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    maven \
    llvm \
    llvm-dev \
    libllvm-ocaml-dev \
    protobuf-compiler \
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
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

# Install clangd 22.1.0
RUN wget -O /tmp/clangd.zip https://github.com/clangd/clangd/releases/download/22.1.0/clangd-linux-22.1.0.zip && \
    unzip -o /tmp/clangd.zip -d /usr/local && \
    mv /usr/local/clangd_22.1.0/bin/clangd /usr/local/bin/clangd && \
    mv /usr/local/clangd_22.1.0/lib/clang /usr/local/lib/ 2>/dev/null || true && \
    rm -rf /usr/local/clangd_22.1.0 /tmp/clangd.zip

RUN mkdir -p /opt/vespa-deps/lib || true
RUN mkdir -p /opt/vespa-deps/include || true

# Install ONNX Runtime
RUN wget -O /tmp/onnxruntime.tgz https://github.com/microsoft/onnxruntime/releases/download/v1.24.4/onnxruntime-linux-x64-1.24.4.tgz && \
    tar -xzf /tmp/onnxruntime.tgz -C /opt && \
    mv /opt/onnxruntime-linux-x64-1.24.4 /opt/onnxruntime && \
    rm /tmp/onnxruntime.tgz && \
    mkdir -p /opt/vespa-deps/include && \
    ln -sf /opt/onnxruntime/include /opt/vespa-deps/include/onnxruntime && \
    ln -sf /opt/onnxruntime/lib/libonnxruntime*.so* /opt/vespa-deps/lib/

WORKDIR /tmp

ENV CMAKE_PREFIX_PATH=/opt/vespa-deps

RUN git clone https://github.com/abseil/abseil-cpp.git /tmp/absl \
 && cd /tmp/absl \
 && cmake -S . -B build \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
 && cmake --build build -j$(nproc) \
 && cmake --install build \
 && rm -rf /tmp/absl

RUN git clone --recursive --branch v33.6 https://github.com/protocolbuffers/protobuf.git

WORKDIR /tmp/protobuf

RUN cmake -S . -B build \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps \
      -Dprotobuf_BUILD_TESTS=OFF \
      -Dprotobuf_ABSL_PROVIDER=module \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
 && cmake --build build -j"$(nproc)" \
 && cmake --install build \
 && rm -rf /tmp/protobuf

RUN cd /tmp \
 && git clone https://github.com/google/benchmark.git \
 && cd benchmark \
 && cmake -S . -B build \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps \
      -DBENCHMARK_DOWNLOAD_DEPENDENCIES=ON \
      -DBENCHMARK_ENABLE_GTEST_TESTS=OFF \
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
 && cmake --build build -j"$(nproc)" \
 && cmake --install build \
 && rm -rf /tmp/benchmark

RUN cd /tmp \
&& git clone https://github.com/google/highway.git \
&& cd highway \
&& cmake -S . -B build \
     -G Ninja \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps \
     -DHWY_ENABLE_TESTS=OFF \
     -DHWY_ENABLE_EXAMPLES=OFF \
     -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
&& cmake --build build -j"$(nproc)" \
&& cmake --install build \
&& rm -rf /tmp/highway

RUN cd /tmp \
&& git clone https://github.com/apache/datasketches-cpp.git \
&& cd datasketches-cpp \
&& cmake -S . -B build \
     -G Ninja \
     -DCMAKE_BUILD_TYPE=Release \
     -DCMAKE_INSTALL_PREFIX=/opt/vespa-deps \
     -DBUILD_TESTS=OFF \
     -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
&& cmake --build build -j"$(nproc)" \
&& cmake --install build \
&& rm -rf /tmp/datasketches-cpp

WORKDIR /
