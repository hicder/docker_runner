FROM hicder/docker_runner_base:latest

WORKDIR /tmp
RUN git clone https://github.com/greenplum-db/gp-xerces.git && cd /tmp/gp-xerces  && mkdir build && cd build && ../configure --prefix=/usr/local && make -j8 && make install
RUN ldconfig
WORKDIR /

