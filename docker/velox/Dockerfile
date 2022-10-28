FROM hicder/docker_runner_base:latest

RUN apt-get install -y libboost-all-dev \
  libdouble-conversion-dev \
  libgoogle-glog-dev \
  libbz2-dev \
  libgflags-dev \
  libgmock-dev \
  libevent-dev \
  liblz4-dev \
  libzstd-dev \
  libre2-dev \
  libsnappy-dev \
  liblzo2-dev \
  bison \
  flex \
  tzdata \
  wget

ENV CC /usr/bin/clang
ENV CXX /usr/bin/clang++

WORKDIR /tmp
RUN git clone -q -b 8.0.0 https://github.com/fmtlib/fmt.git && mkdir -p fmt/.build && cd fmt/.build && cmake -DCMAKE_BUILD_TYPE=Release -GNinja -DBUILD_TESTING=OFF -DCMAKE_CXX_STANDARD=17 -DFMT_TEST=OFF ..  && ninja install

WORKDIR /opt/src
